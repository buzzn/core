class Buzzn::Security::SecureHashSerializerCore
  include Import['service.message_encryptor']

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
class Buzzn::Security::SecureHashSerializer

  def core
    @core ||= Buzzn::Security::SecureHashSerializerCore.new
  end

  def load(encrypted)
    core.load(encrypted)
  end
   
  def dump(hash)
    core.dump(hash)
  end
end
