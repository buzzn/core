class Buzzn::Services::MessageEncrypter < ActiveSupport::MessageEncryptor

  def self.new
    # a brief verification indicates that the ActiveSupport::MessageEncryptor
    # is threadsafe and can be used by mutliple threads concurrently
    super(Buzzn::Application.secrets.secret_key_base)
  end

end
