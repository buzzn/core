class OrganizationResource < Buzzn::Resource::Entity
  include BankAccountResource::Create

  model Organization

  attributes  :name,
              :phone,
              :fax,
              :website,
              :email,
              :description,
              :customer_number

  attributes :updatable, :deletable

  has_one :address
  has_one :contact
  has_one :legal_representation

  has_many :bank_accounts

end
