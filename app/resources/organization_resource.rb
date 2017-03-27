class OrganizationResource < Buzzn::EntityResource

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
  has_one :bank_account

  # API methods for endpoints

  def members
    object.members.readable_by(@current_user)
  end

  def managers
    object.managers.readable_by(@current_user)
  end

end
class FullOrganizationResource < OrganizationResource

  def self.new(*args)
    super
  end

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number
end

# TODO get rid of the need of having a Serializer class
class OrganizationSerializer < OrganizationResource
  def self.new(*args)
    super
  end
end
