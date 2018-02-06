def info(contract)
  i = ""
  i << "Vertrag #{contract.contract_number}/#{contract.contract_number_addition}"
  i << "\nLocalpool: #{contract.localpool.name}"
  i << "\nKunde: #{contract.customer.name}"
  i << "\nVertragsgeber: #{contract.contractor.name}"
  i << "\nRegister: #{contract.register.name}"
  i << if contract.status.ended?
    "\nVertrags-Zeitraum: s#{contract.begin_date} - #{contract.end_date} (beendet)"
  else
    "\nVertrags-Zeitraum: #{contract.begin_date} - heute"
  end
  i
end

Contract::LocalpoolPowerTaker
  .joins(:localpool)
  .where("groups.name !~ 'Localpool|Testgruppe'")
  .order(:contract_number, :contract_number_addition).each do |contract|
  case contract.status
  when 'ended'
    unless contract.begin_reading && contract.end_reading
      puts "\n* #{info(contract)}"
      puts "-> Zählerstand zu Vertragsbeginn fehlt" if contract.begin_reading.nil?
      puts "-> Zählerstand zu Vertragsende fehlt" if contract.begin_reading.nil?
    end
  when 'active', 'terminated'
    unless contract.begin_reading
      puts "\n* #{info(contract)}"
      puts "-> Zählerstand zu Vertragsbeginn fehlt" if contract.begin_reading.nil?
    end
  when 'onboarding'
    # no readings expected yet
  else
    puts "Unknown status: #{contract.status}"
  end
end
