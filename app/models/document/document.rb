require 'buzzn/security/secure_hash_serializer'
require 'buzzn/crypto/decryptor'
require 'buzzn/crypto/encryptor'
require 'magic'

class Document < ActiveRecord::Base

  include Import.active_record['services.storage']

  serialize :encryption_details, Security::SecureHashSerializer.new

  attr_readonly :filename

  validates :filename, presence: true
  validates :sha256, presence: true

  has_many :contract_documents
  has_many :billing_documents
  has_many :group_documents
  has_many :pdf_documents

  before_destroy :check_relations

  def check_relations
    if referenced?
      throw(:abort)
    end
  end

  def referenced?
    contract_documents.any? ||
      billing_documents.any? ||
      group_documents.any? ||
      pdf_documents.any?
  end

  def read
    encrypted = storage.files.get(self.path).body
    Crypto::Decryptor.new(self.encryption_details).process(encrypted)
  end

  def path
    dir = self.sha256[-2..-1]
    'sha256/' + dir + '/' + self.sha256
  end

  def store(data)
    sha256 = Digest::SHA256.new
    self.sha256 = sha256.hexdigest(data)
    self.mime = Magic.guess_string_mime_type(data)
    self.size = data.length

    encrypted = Crypto::Encryptor.new.process(data)
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
    unless Document.where(:sha256 => self.sha256).count > 1
      storage.files.get(self.path).destroy
    end
    super
  end

  def filename=(value)
    super(File.basename(value))
  end

  def self.create(filename, data)
    document = new(:filename => filename)
    document.store(data)
    document
  end

end
