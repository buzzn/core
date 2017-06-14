require_relative 'user_resource'
class ContractingPartyUserResource < UserResource
  include BankAccountResource::Create

  def self.new(*args)
    super
  end

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number

  def deletable
    if object == current_user
      false
    else
      super
    end
  end
end
