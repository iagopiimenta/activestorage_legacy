# Provides the class-level DSL for declaring that an Active Record model has attached blobs.

module ActiveStorage::Patches::ActiveRecord
  class MinimumLengthError < StandardError; end
  MINIMUM_TOKEN_LENGTH = 24

  def has_secure_token(attribute = :token, length: MINIMUM_TOKEN_LENGTH)
    if length < MINIMUM_TOKEN_LENGTH
      raise MinimumLengthError, "Token requires a minimum length of #{MINIMUM_TOKEN_LENGTH} characters."
    end

    define_method("regenerate_#{attribute}") { update_attributes! attribute => self.class.generate_unique_secure_token(length: length) }
    before_create { send("#{attribute}=", self.class.generate_unique_secure_token(length: length)) unless send("#{attribute}?") }
  end

  def generate_unique_secure_token(length: MINIMUM_TOKEN_LENGTH)
    SecureRandom.base58(length)
  end
end
