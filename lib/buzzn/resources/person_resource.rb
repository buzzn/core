require_relative 'bank_account_resource'

class PersonResource < Buzzn::Resource::Entity

  model Person

  attributes  :prefix,
              :title,
              :first_name,
              :last_name,
              :phone,
              :fax,
              :email,
              :preferred_language,
              :image,
              :customer_number,
              :email_backend_host,
              :email_backend_port,
              :email_backend_user,
              :email_backend_encryption

  attributes :updatable, :deletable

  has_one :address

  has_many :bank_accounts
  has_many :contracts

  def image
    object.image.medium.url
  end

  def customer_number
    object.customer_number&.id
  end

end
