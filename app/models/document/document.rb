require 'buzzn/security/secure_hash_serializer'
require 'buzzn/crypto/decryptor'
require 'buzzn/crypto/encryptor'
require 'magic'

class Document < ActiveRecord::Base

  include Import.active_record['services.storage']

  serialize :encryption_details, Security::SecureHashSerializer.new

  attr_readonly :filename

  attr_accessor :data

  validates :filename, presence: true
  validates :sha256, presence: true
  validates :sha256_encrypted, presence: true

  has_many :contract_documents, dependent: :destroy
  has_many :billing_documents, dependent: :destroy
  has_many :group_documents, dependent: :destroy
  has_many :pdf_documents, dependent: :destroy

  before_validation :check_and_store_data

  def check_and_store_data
    if sha256_of_data(self.data) != self.sha256
      self.store
    end
  end

  def read
    encrypted = storage.files.get(self.path).body
    Crypto::Decryptor.new(self.encryption_details).process(encrypted)
  end

  def path
    dir = self.sha256_encrypted[-2..-1]
    'sha256/' + dir + '/' + self.sha256_encrypted
  end

  def store
    self.sha256 = sha256_of_data(self.data)
    self.mime = Magic.guess_string_mime_type(self.data)
    self.size = data.length

    encrypted = Crypto::Encryptor.new.process(self.data)
    self.sha256_encrypted = sha256_of_data(encrypted.data)
    self.encryption_details = encrypted.details
    if valid?
      storage.files.create(
        :body         => encrypted.data,
        :key          => self.path,
        :public       => false
      )
    end
    self.save!
  end

  def destroy
    # deduplication, only delete if last reference
    unless Document.where(:sha256_encrypted => self.sha256_encrypted).count > 1
      storage.files.get(self.path).destroy
    end
    super
  end

  def filename=(value)
    super(File.basename(value))
  end

  private

  def sha256_of_data(data)
    sha256 = Digest::SHA256.new
    sha256.hexdigest(data)
  end

end
