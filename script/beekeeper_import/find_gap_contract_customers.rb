# Because 'rails runner <scriptname>' doesn't work anymore, you'll have to run this script like this:
# $ bin/console
# > load '<scriptname>'

def common_consumption_contracts(group)
  # 1. get all common consumption market locations
  common_consumption_mls = group.market_locations.to_a.select do |ml|
    ml.register.label.to_sym == :consumption_common
  end
  # return the active contract of every market location
  common_consumption_mls.map { |ml| ml.contracts.find { |c| c.end_date.nil? } }.compact
end

def common_consumption_contracts_with_customers(group)
  contracts = common_consumption_contracts(group)
  contracts.group_by(&:customer)
end

all_groups = Group::Base
             .where("name !~ 'Localpool|Testgruppe'")
             .where("start_date <= ?", Date.today)
             .where(gap_contract_customer_person_id: nil, gap_contract_customer_organization_id: nil)
             .order(:start_date, :name)

all_groups.each do |group|
  puts
  print group.name
  print ": "
  customers_and_contracts = common_consumption_contracts_with_customers(group)
  case customers_and_contracts.size
  when 0
    print 'No common consumption contracts!'
  when 1
    customer  = customers_and_contracts.keys.first
    contracts = customers_and_contracts.values.first
    contract = contracts.min_by(&:contract_number_addition) # pick the one with the lowest addition
    contract_nr = "#{contract.contract_number}/#{contract.contract_number_addition}"
    print "#{contract_nr} (#{customer.name})"
  else
    print 'More than one customer for common consumption contracts!'
  end
  # customers_and_contracts.each do |customer, contracts|
  #   p customer
  #   p contracts
  # end
  # contracts = common_consumption_contracts_of_group_owner(group)
  # if contracts.empty?
  #   puts "#{group.name}: ----"
  # else
  #   c = contracts.min_by(&:contract_number_addition)
  #   puts "#{group.name}: #{c.contract_number}/#{c.contract_number_addition}"
  # end
end
