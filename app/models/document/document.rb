require 'buzzn/security/secure_hash_serializer'
require 'buzzn/crypto/decryptor'
require 'buzzn/crypto/encryptor'
require 'magic'

class Document < ActiveRecord::Base

  include Import.active_record['services.storage']

  serialize :encryption_details, Security::SecureHashSerializer.new

  attr_readonly :path

  validates :path, presence: true, uniqueness: true

  has_many :contract_documents
  has_many :billing_documents
  has_many :group_documents
  has_many :pdf_documents

  before_destroy :check_relations

  def check_relations
    if is_referenced?
      throw(:abort)
    end
  end

  def is_referenced?
    contract_documents.any? ||
      billing_documents.any? ||
      group_documents.any? ||
      pdf_documents.any?
  end

  def read
    encrypted = storage.files.get(self.path).body
    Crypto::Decryptor.new(self.encryption_details).process(encrypted)
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
    storage.files.get(self.path).destroy
    super
  end

  def self.create(path, data)
    document = new(:path => path)
    document.store(data)
    document
  end

end
