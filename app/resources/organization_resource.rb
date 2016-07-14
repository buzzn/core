class OrganizationResource < ApplicationResource

  attributes  :name,
              :phone,
              :fax,
              :website,
              :email,
              :description,
              :mode

  has_one :address
  has_one :contracting_party
  has_one :iln

  has_many :contracts
end
