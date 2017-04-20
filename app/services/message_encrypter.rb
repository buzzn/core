class Buzzn::Services::MessageEncrypter < ActiveSupport::MessageEncryptor

  def self.new
    super(Buzzn::Application.secrets.secret_key_base)
  end

end
