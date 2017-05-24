class UserResource < Buzzn::EntityResource

  model User

  attributes  :user_name,
              :title,
              :first_name,
              :last_name,
              :gender,
              :phone,
              :email

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
end

class MentorResource < Buzzn::EntityResource

  model User

  attributes  :first_name,
              :last_name,
              :image

  def image
    object.image.md.url
  end
end

class ContractingPartyUserResource < UserResource
  include BankAccountResource::Create

  def self.new(*args)
    super
  end

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number
end
