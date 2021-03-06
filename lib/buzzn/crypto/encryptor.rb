require_relative '../crypto'

class Crypto::Encryptor

  # authenticated encryption
  # see also https://crypto.stanford.edu/RealWorldCrypto/slides/gueron.pdf
  # TODO use AES-SIV from https://github.com/miscreant/miscreant/wiki/Ruby-Documentation
  #      inspired by https://youtu.be/3t3P7kzdP4M?t=2373
  CIPHER_ALGORITHM = 'aes-128-gcm'

  def process(data)
    (cipher, details) = build_cipher

    encrypted          = cipher.update(data) + cipher.final
    details[:auth_tag] = cipher.auth_tag

    OpenStruct.new(data: encrypted, details: details)
  end

  private
  def build_cipher
    details = Hash.new
    details[:cipher] = CIPHER_ALGORITHM

    cipher = OpenSSL::Cipher.new(details[:cipher])
    cipher.encrypt
    cipher.key       = details[:key]       = cipher.random_key
    cipher.iv        = details[:iv]        = cipher.random_iv
    cipher.auth_data = details[:auth_data] = SecureRandom.random_bytes(16)

    [cipher, details]
  end

end
