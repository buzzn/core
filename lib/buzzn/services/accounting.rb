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

  def balance_at(entry)
    contract = entry.contract
    amount = 0
    # traverse until nil FIXME: speedup
    loop do
      if entry.contract == contract
        amount += entry.amount
      end
      # end of chain
      if entry.previous_checksum.nil?
        break
      end
      entry = Accounting::Entry.where(:checksum => entry.previous_checksum).first
      if entry.nil?
        raise Buzzn::GeneralError 'Accounting inconsistency'
      end
    end
    amount
  end

end
