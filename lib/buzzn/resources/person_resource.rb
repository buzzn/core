require_relative 'bank_account_resource'
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
              :preferred_language,
              :image

  attributes :updatable, :deletable

  has_many :bank_accounts

  def image
    user = User.where(person: object).first
    if user
      user.image.md.url
    elsif object.image
      object.image.md.url
    else
    end
  end
end
