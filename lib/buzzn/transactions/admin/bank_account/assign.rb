require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/assign'

class Transactions::Admin::BankAccount::Assign < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_bank_account
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::BankAccount::Assign
  end

  def check_bank_account(params:, resource:, person_or_org:, attribute:)
    person_or_org = resource.object.send(person_or_org)
    if person_or_org.nil?
      raise Buzzn::ValidationError.new({"#{person_or_org}": ["must be assigned first"]}, resource.object)
    end

    begin
      bank_account = person_or_org.bank_accounts.find(params.delete(:bank_account_id))
    rescue ActiveRecord::RecordNotFound
      raise Buzzn::ValidationError.new({bank_account: ["does not exist or belong to #{person_or_org.class.name.downcase} #{person_or_org.id}"]}, resource.object)
    end
    params[attribute] = bank_account
  end

end
