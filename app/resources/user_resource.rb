class UserSerializer < ActiveModel::Serializer
end
class FullUserSerializer < UserSerializer

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
class GuardedUserSerializer < UserSerializer

  attributes :updatable, :deletable

  def initialize(user, *args)
    super(*args)
    @current_user = user
  end

  def updatable
    object.updatable_by?(@current_user)
  end

  def deletable
    object.deletable_by?(@current_user)
  end
end
