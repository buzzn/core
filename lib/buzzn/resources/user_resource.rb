class UserResource < Buzzn::Resource::Entity
  include BankAccountResource::Create

  model User

  attributes  :user_name,
              :title,
              :first_name,
              :last_name,
              :gender,
              :phone,
              :email,
              :image

  attributes :updatable, :deletable

  has_many :bank_accounts

  def title
    object.profile.title
  end

  def gender
    object.profile.gender
  end

  def phone
    object.profile.phone
  end

  def image
    object.image.md.url
  end
end
