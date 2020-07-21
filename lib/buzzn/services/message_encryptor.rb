require_relative '../services'

# a brief verification indicates that the ActiveSupport::MessageEncryptor
# is threadsafe and can be used by multiple threads concurrently
class Services::MessageEncryptor < ActiveSupport::MessageEncryptor

  def self.new
    # https://github.com/rails/rails/issues/25448#issuecomment-441832416
    secret = Import.global('config.secret_key_base')
    super(secret[0..31], secret)
  end

end
