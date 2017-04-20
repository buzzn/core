class Document < ActiveRecord::Base
  include Import.reader['service.storage']

  serialize :encryption_details, Buzzn::Security::SecureHashSerializer.new

  attr_readonly :path, :encryption_details

  def read
    encrypted = storage.files.get(self.file_path).body
    Buzzn::Crypto::Decryptor.new(self.file_encryption_details)
      .process(encrypted)
  end

  def store(data)
    encrypted = Buzzn::Crypto::Encryptor.new.process(data)
    self.encryption_details = encrypted.details
    storage.files.create({
      :body         => encrypted.data,
      :key          => self.file_path,
      :public       => false
    })
    self.save
  end

  def self.create(path, data)
    document = new(:path => path)
    document.store(data)
  end
end
