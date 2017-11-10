class Document < ActiveRecord::Base
  include Import.active_record['service.storage']

  serialize :encryption_details, Buzzn::Security::SecureHashSerializer.new

  attr_readonly :path#, :encryption_details

  validates :path, presence: true, uniqueness: true

  def read
    encrypted = storage.files.get(self.path).body
    Buzzn::Crypto::Decryptor.new(self.encryption_details)
      .process(encrypted)
  end

  def store(data)
    encrypted = Buzzn::Crypto::Encryptor.new.process(data)
    self.encryption_details = encrypted.details
    if valid?
      storage.files.create({
        :body         => encrypted.data,
        :key          => self.path,
        :public       => false
      })
    end
    self.save!
  end

  def destroy
    storage.files.get(self.path).destroy
    super
  end

  def self.create(path, data)
    document = new(:path => path)
    document.store(data)
    document
  end
end
