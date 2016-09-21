class OrganizationResource < ApplicationResource

  attributes  :name,
              :phone,
              :fax,
              :website,
              :email,
              :description,
              :mode,
              :authority,
              :retailer,
              :provider_permission

  has_one :address
  has_one :contracting_party
  has_one :iln

  has_many :contracts
end
