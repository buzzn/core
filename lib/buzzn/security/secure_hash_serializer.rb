require_relative '../security'

class Security::SecureHashSerializerCore
  include Import['services.message_encryptor']

  def load(encrypted)
    if encrypted.present?
      string = message_encryptor.decrypt_and_verify(encrypted)
      YAML.load(string)
    else
      {}
    end
  end

  def dump(hash)
    if hash.present?
      string = YAML.dump(hash)
      message_encryptor.encrypt_and_sign(string)
    end
  end
end
class Security::SecureHashSerializer

  def core
    @core ||= Security::SecureHashSerializerCore.new
  end

  def load(encrypted)
    core.load(encrypted)
  end

  def dump(hash)
    core.dump(hash)
  end
end
