class UserResource < Buzzn::EntityResource

  model User

  attributes :updatable, :deletable

  # API methods for endpoints

  entities :profile,
           :bank_account

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
              :email,
              :sales_tax_number,
              :tax_rate,
              :tax_number

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

# TODO get rid of the need of having a Serializer class
class UserSerializer < UserResource
  def self.new(*args)
    super
  end
end
