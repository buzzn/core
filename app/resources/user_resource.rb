class UserResource < Buzzn::EntityResource

  model User

  attributes :updatable, :deletable

  # API methods for endpoints

  entities :profile,
           :bank_account

  def meters(filter = nil)
    Meter::Base.filter(filter).readable_by(@current_user)
  end

end

class FullUserResource < UserResource

  def self.new(*args)
    super
  end

  attributes  :user_name,
              :title,
              :first_name,
              :last_name,
              :gender,
              :phone,
              :email

  def title
    object.profile.title
  end

  def gender
    object.profile.gender
  end

  def phone
    object.profile.phone
  end
end

class ContractingPartyUserResource < FullUserResource
  def self.new(*args)
    super
  end

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number

end

# TODO get rid of the need of having a Serializer class
class UserSerializer < UserResource
  def self.new(*args)
    super
  end
end
