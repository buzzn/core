class PersonResource < Buzzn::Resource::Entity
  include BankAccountResource::Create

  model Person

  attributes  :prefix,
              :title,
              :first_name,
              :last_name,
              :phone,
              :fax,
              :email,
              :share_with_group,
              :share_publicly,
              :preferred_language,
              :image

  attributes :updatable, :deletable

  has_many :bank_accounts

  def image
    # TODO move image to person
    user = User.where(person: object).first
    user.image.md.url if user
  end
end
