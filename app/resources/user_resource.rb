class UserResource < Buzzn::EntityResource

  model User

  attributes :updatable, :deletable

  # API methods for endpoints

  entities :profile,
           :bank_account

  def meters(filter = nil)
    Meter::Base.filter(filter).readable_by(@current_user).collect { |m| Meter::BaseResource.new(m) }
  end

end

class UserSingleResource < UserResource

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

class ContractingPartyUserSingleResource < UserSingleResource
  def self.new(*args)
    super
  end

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number

end

class UserCollectionResource < UserResource
end
