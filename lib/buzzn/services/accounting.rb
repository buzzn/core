require_relative '../services'

class Services::Accounting

  def book(booked_by, contract, amount, comment: nil, external_reference: nil)
    attrs = {
      booked_by: booked_by,
      contract: contract,
      amount: amount,
    }.tap do |h|
      h[:comment] = comment unless comment.nil?
      h[:external_reference] = external_reference unless external_reference.nil?
    end
    Accounting::Entry.create(attrs)
  end

  def balance(contract)
    Accounting::Entry.for_contract(contract).collect(&:amount).reduce(:+) || 0
  end

end
