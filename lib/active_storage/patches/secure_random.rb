require "securerandom"

module SecureRandom
  BASE58_ALPHABET = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a - ["0", "O", "I", "l"] unless defined?(BASE58_ALPHABET)
  BASE36_ALPHABET = ("0".."9").to_a + ("a".."z").to_a unless defined?(BASE36_ALPHABET)

  unless SecureRandom.methods.include?(:base58)
    def self.base58(n = 16)
      SecureRandom.random_bytes(n).unpack("C*").map do |byte|
        idx = byte % 64
        idx = SecureRandom.random_number(58) if idx >= 58
        BASE58_ALPHABET[idx]
      end.join
    end
  end

  unless SecureRandom.methods.include?(:base36)
    def self.base36(n = 16)
      SecureRandom.random_bytes(n).unpack("C*").map do |byte|
        idx = byte % 64
        idx = SecureRandom.random_number(36) if idx >= 36
        BASE36_ALPHABET[idx]
      end.join
    end
  end
end
