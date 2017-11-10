require_relative 'bank_account_resource'
class PersonResource < Buzzn::Resource::Entity
  include BankAccountResource::Create

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
              :customer_number

  attributes :updatable, :deletable

  has_one :address

  has_many :bank_accounts

  def image
    object.image.md.url
  end
end
