class OrganizationResource < Buzzn::Resource::Entity
  include BankAccountResource::Create

  model Organization

  attributes  :name,
              :phone,
              :fax,
              :website,
              :email,
              :description,
              :mode

  attributes :updatable, :deletable

  has_one :address

  has_many :bank_accounts

end
