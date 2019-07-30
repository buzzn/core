class OrganizationResource < Buzzn::Resource::Entity

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

  def customer_number
    object.customer_number&.id
  end

end
