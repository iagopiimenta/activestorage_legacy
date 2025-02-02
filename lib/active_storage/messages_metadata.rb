class ActiveSupport::MessagesMetadata #:nodoc:
  def initialize(message, expires_at = nil, purpose = nil)
    @message, @expires_at, @purpose = message, expires_at, purpose
  end

  def as_json(options = {})
    { _rails: { message: @message, exp: @expires_at, pur: @purpose } }
  end

  class << self
    def wrap(message, expires_at: nil, expires_in: nil, purpose: nil)
      if expires_at || expires_in || purpose
        ActiveSupport::JSON.encode new(encode(message), pick_expiry(expires_at, expires_in), purpose)
      else
        message
      end
    end

    def verify(message, purpose)
      extract_metadata(message).verify(purpose)
    end

    private
    def pick_expiry(expires_at, expires_in)
      if expires_at
        expires_at.utc.iso8601(3)
      elsif expires_in
        Time.now.utc.advance(seconds: expires_in).iso8601(3)
      end
    end

    def extract_metadata(message)
      data = ActiveSupport::JSON.decode(message) rescue nil

      if data.is_a?(Hash) && data.key?("_rails")
        new(decode(data["_rails"]["message"]), data["_rails"]["exp"], data["_rails"]["pur"])
      else
        new(message)
      end
    end

    def encode(message)
      ::Base64.strict_encode64(message)
    end

    def decode(message)
      ::Base64.strict_decode64(message)
    end
  end

  def verify(purpose)
    @message if match?(purpose) && fresh?
  end

  private
  def match?(purpose)
    @purpose.to_s == purpose.to_s
  end

  def fresh?
    @expires_at.nil? || Time.now.utc < Time.iso8601(@expires_at)
  end
end

