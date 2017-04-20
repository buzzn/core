class Buzzn::Security::SecureHashSerializer
  include Import['service.message_encrypter']

  def load encrypted
    if encrypted.present?
      string = message_encrypter.decrypt_and_verify(encrypted)
      YAML.load(string)
    else
      {}
    end
  end

  def dump hash
    if hash.present?
      string = YAML.dump(hash)
      message_encrypter.encrypt_and_sign(string)
    end
  end
end
