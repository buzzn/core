class OrganizationResource < Buzzn::Resource::Entity

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
