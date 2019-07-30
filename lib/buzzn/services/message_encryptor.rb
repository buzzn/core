require_relative '../services'

# a brief verification indicates that the ActiveSupport::MessageEncryptor
# is threadsafe and can be used by multiple threads concurrently
class Services::MessageEncryptor < ActiveSupport::MessageEncryptor

  def self.new
    super(Import.global('config.secret_key_base'))
  end

end
