class OrganizationSerializer < ActiveModel::Serializer

  attributes  :name,
              :phone,
              :fax,
              :website,
              :email,
              :description,
              :mode

  has_one :address
  has_one :bank_account
end
class FullOrganizationSerializer < OrganizationSerializer

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number
end
