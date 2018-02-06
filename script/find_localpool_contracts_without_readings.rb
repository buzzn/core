def info(contract)
  i = ""
  i << "Vertrag #{contract.contract_number}/#{contract.contract_number_addition}"
  i << if contract.status.ended?
    "\nZeitraum: #{contract.begin_date} - #{contract.end_date} (beendet)"
  else
    "\nZeitraum: #{contract.begin_date} - heute"
  end
  i << "\nLocalpool: #{contract.localpool.name}"
  i << "\nKunde: #{contract.customer.name}"
  i << "\nVertragsgeber: #{contract.contractor.name}"
  i << "\nRegister: #{contract.register.name}"
  i
end

def billing_start_reading(contract)
  if contract.begin_date.year >= 2017
    contract.begin_reading
  else
    contract.register.readings.find_by(date: ["2016-12-31", "2017-01-01"])
  end
end

def billing_end_reading(contract)
  contract.end_reading
end

def contract_needs_to_be_billed?(contract)
  if contract.status.ended?
    contract.end_date.year >= 2017
  elsif contract.status.terminated?
    true
  elsif contract.status.active?
    true
  end
end

Contract::LocalpoolPowerTaker
  .joins(:localpool)
  .where("groups.name !~ 'Localpool|Testgruppe'")
  .order(:contract_number, :contract_number_addition).each do |contract|

  # next unless contract_needs_to_be_billed?(contract)

  # if "#{contract.contract_number}/#{contract.contract_number_addition}"== "60006/2"
  # end

  case contract.status
  when 'ended'
    unless billing_start_reading(contract) && billing_end_reading(contract)
      puts "\n* #{info(contract)}"
      puts "-> Zählerstand zu Jahres- oder Vertragsbeginn fehlt" if billing_start_reading(contract).nil?
      puts "-> Zählerstand zu Vertragsende fehlt" if billing_end_reading(contract).nil?
    end
  when 'active', 'terminated'
    unless billing_start_reading(contract)
      puts "\n* #{info(contract)}"
      puts "-> Zählerstand zu Jahres- oder Vertragsbeginn fehlt"
    end
  when 'onboarding'
    # no readings expected yet
  else
    puts "Unknown status: #{contract.status}"
  end
end
