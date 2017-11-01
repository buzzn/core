Fabricator :payment, class_name: Contract::Payment do
  begin_date    { FFaker::Time.date }
  price_cents   { rand(100) + 1 }
  cycle         { Contract::Payment::MONTHLY }
end

Fabricator :tariff, class_name: Contract::Tariff do
  name                      { FFaker::Name.name }
  begin_date                { FFaker::Time.date }
  energyprice_cents_per_kwh { rand(100) + 1 }
  baseprice_cents_per_month { rand(10) + 1 }
end

Fabricator :tariff_forstenried, from: :tariff do
  begin_date                { Date.new(2014, 12, 15) }
  energyprice_cents_per_kwh { 25.5 }
  baseprice_cents_per_month { 250 }
end

Fabricator :tariff_sulz, from: :tariff do
  begin_date                { Date.new(2016, 8, 4) }
  energyprice_cents_per_kwh { 23.8 }
  baseprice_cents_per_month { 500 }
end


# == Metering Point Operator Contract ==

Fabricator :metering_point_operator_contract, class_name: Contract::MeteringPointOperator do
  metering_point_operator_name { FFaker::Name.name }
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          { rand(90000) + 1 }
  contract_number_addition { rand(10000) + 1 }
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  customer                 {
    user = Fabricate(:person)
    user.update(address: Fabricate(:address))
    user
  }
  contractor               { Organization.discovergy }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor)
    c.customer_bank_account = Fabricate(:bank_account, owner: c.customer)
    c.save
  end
end

Fabricator :metering_point_operator_contract_of_localpool, from: :metering_point_operator_contract do
  localpool { Fabricate(:localpool) }
end

Fabricator :metering_point_operator_contract_of_register, from: :metering_point_operator_contract do
  register { Fabricate(:meter).registers.first }
end

Fabricator :metering_point_operator_contract_of_localpool_for_organization, from: :metering_point_operator_contract_of_localpool do
  customer     { Fabricate(:other_organization) }
end

Fabricator :metering_point_operator_contract_of_register_for_organization, from: :metering_point_operator_contract_of_register do
  customer     { Fabricate(:other_organization) }
end

# == Other Supplier Contract ==

Fabricator :other_supplier_contract, class_name: Contract::OtherSupplier do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          { rand(60000) + 1 }
  contract_number_addition { rand(10000) + 1 }
  power_of_attorney        true
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:person) }
  register                 { Fabricate(:input_register,
                                       meter: Fabricate.build(:output_meter)) }
                                       #address: Fabricate.build(:address) ) }
  renewable_energy_law_taxation Contract::Base::FULL
end

# == Power Taker Contract ==

Fabricator :power_taker_contract, class_name: Contract::PowerTaker do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          { rand(20000) + 1 }
  contract_number_addition { rand(10000) + 1 }
  begin_date               { FFaker::Time.date }
  power_of_attorney        true
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:person) }
  register                 { Fabricate(:input_register,
                                       meter: Fabricate.build(:output_meter)) }
#                                       address: Fabricate.build(:address) ) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor)
    c.customer_bank_account = Fabricate(:bank_account, owner: c.customer)
    c.save
  end
end

Fabricator :power_taker_contract_move_in, from: :power_taker_contract do
  begin_date               { FFaker::Time.date }
end

Fabricator :power_taker_contract_old_contract, from: :power_taker_contract do
  old_supplier_name   { FFaker::Name.name }
  old_customer_number { FFaker::Product.letters(8) }
  old_account_number  { FFaker::Product.letters(12) }
end

Fabricator :power_taker_contract_move_in_for_organization, from: :power_taker_contract_move_in do
  customer     { Fabricate(:other_organization) }
end

Fabricator :power_taker_contract_old_contract_for_organization, from: :power_taker_contract_old_contract do
  customer     { Fabricate(:other_organization) }
end

# == Power Giver Contract ==

Fabricator :power_giver_contract, class_name: Contract::PowerGiver do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          { rand(40000) + 1 }
  contract_number_addition { rand(10000) - 1 }
  power_of_attorney        true
  confirm_pricing_model    true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  register                 { Fabricate(:output_register,
                                       meter: Fabricate.build(:input_meter)) }
#                                       address: Fabricate.build(:address) ) }
  customer                 { Fabricate(:person) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor)
    c.customer_bank_account = Fabricate(:bank_account, owner: c.customer)
    c.save
  end
end

Fabricator :power_giver_contract_for_organization, from: :power_giver_contract do
  customer     { Fabricate(:other_organization) }
end

# == Localpool Power Taker Contract ==

Fabricator :localpool_power_taker_contract, class_name: Contract::LocalpoolPowerTaker do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          { rand(60000) + 1 }
  contract_number_addition { rand(10000) + 1 }
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:person) }
  contractor               { Fabricate(:person) }
  register                 { Fabricate(:input_register,
                                       group: Fabricate(:localpool),
                                       meter: Fabricate.build(:output_meter)) }
#                                       address: Fabricate.build(:address) ) }
  renewable_energy_law_taxation { Contract::Base::FULL }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
  after_create do |c|
    c.customer.add_role(Role::CONTRACT, c) if c.customer.is_a? Person
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor) unless c.contractor_bank_account
    c.customer_bank_account = Fabricate(:bank_account, owner: c.customer) unless c.customer_bank_account
    c.save
  end
end

Fabricator :localpool_power_taker_contract_for_organization, from: :localpool_power_taker_contract do
  customer     { Fabricate(:other_organization) }
end


# == Localpool Processing Contract ==

Fabricator :localpool_processing_contract, class_name: Contract::LocalpoolProcessing do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          { rand(60000) + 1 }
  contract_number_addition 0
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:person) }
  localpool                { Fabricate(:localpool) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
  contractor               { Organization.buzzn_systems }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor)
    c.customer_bank_account = Fabricate(:bank_account, owner: c.customer)
    c.save
  end
end

Fabricator :localpool_processing_contract_for_organization, from: :localpool_processing_contract do
  customer     { Fabricate(:other_organization) }
end


Fabricator :mpoc_buzzn_metering, from: :metering_point_operator_contract do
  contractor    { Organization.buzzn_energy }
  tariffs       { [Fabricate.build(:tariff)] }
  payments      { [Fabricate.build(:payment)] }
end

Fabricator :mpoc_stefan, from: :metering_point_operator_contract do
  contractor     { Organization.discovergy }
  register       { Fabricate(:easymeter_1024000034).registers.first }
end

Fabricator :mpoc_karin, from: :metering_point_operator_contract do
  contractor    { Organization.discovergy }
  customer      { Fabricate(:karin) }
  register      { Fabricate(:easymeter_60051431).output_register }
end

# == Localpool Contracts for Mehrgenerationenplatz Forstenried ==

Fabricator :lpc_forstenried, from: :localpool_processing_contract do
  begindate = Date.new(2014, 12, 1)
  customer_number '40021/1'
  contract_number          60015
  contract_number_addition 0
  begin_date      begindate
  signing_date    begindate - 2.months
  tariffs         { [Fabricate.build(:tariff,
                      name: 'localpool_processing_standard',
                      begin_date: begindate,
                      end_date: begindate,
                      energyprice_cents_per_kwh: 0,
                      baseprice_cents_per_month: 100000)] }
  payments        { [Fabricate.build(:payment,
                      begin_date: begindate,
                      end_date: begindate,
                      price_cents: 100000,
                      cycle: Contract::Payment::ONCE),
                    Fabricate.build(:payment,
                      begin_date: begindate,
                      end_date: begindate,
                      price_cents: 100000,
                      cycle: Contract::Payment::ONCE)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor)
    c.customer_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :mpoc_forstenried, from: :metering_point_operator_contract do
  begindate = Date.new(2014, 12, 1)
  metering_point_operator_name  'buzzn systems UG'
  customer_number               '40021/1'
  contract_number               90041
  contract_number_addition      0
  begin_date                    begindate
  signing_date                  begindate - 2.months
  contractor                    { Organization.buzzn_systems }
  tariffs                       { [Fabricate.build(:tariff,
                                    name: 'metering_standard',
                                    begin_date: begindate,
                                    end_date: nil,
                                    energyprice_cents_per_kwh: 0,
                                    baseprice_cents_per_month: 30000)] }
  payments                      { [Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate,
                                    price_cents: 30000,
                                    cycle: Contract::Payment::ONCE),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate,
                                    price_cents: 30000,
                                    cycle: Contract::Payment::ONCE),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: nil,
                                    price_cents: 55000,
                                    cycle: Contract::Payment::MONTHLY),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate.end_of_year,
                                    price_cents: 55000,
                                    cycle: Contract::Payment::MONTHLY),
                                  Fabricate.build(:payment,
                                    begin_date: begindate.next_year.beginning_of_year,
                                    end_date: begindate.next_year.end_of_year,
                                    price_cents: 55000,
                                    cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account, owner: c.contractor)
    c.customer_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

# == Localpool Power Taker Contracts for Mehrgenerationenplatz Forstenried ==

Fabricator :lptc_mabe, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        1
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1495
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 3500,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_inbr, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        2
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1480
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 3400,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_pebr, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        3
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 651
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 1600,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_anbr, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        4
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2275
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 5100,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_gubr, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 15)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        5
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 621
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 1600,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_mabr, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        6
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1000
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 2400,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_dabr, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        7
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2800
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 6200,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_zubu, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        8
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 4000
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 8800,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_mace, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        9
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1000
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 2400,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_stcs, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 15)
  signingdate = Date.new(2014, 12, 1)
  contract_number                 60015
  contract_number_addition        10
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 900
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 2200,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_pafi, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 1)
  cancellationdate = Date.new(2016, 1, 1)
  enddate = Date.new(2016, 4, 28)
  contract_number                 60015
  contract_number_addition        11
  begin_date                      begindate
  end_date                        enddate
  signing_date                    signingdate
  termination_date               cancellationdate
  forecast_kwh_pa                 1800
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: enddate,
                                      price_cents: 4100,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end

Fabricator :lptc_raja, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 5, 1)
  signingdate = Date.new(2016, 2, 1)
  contract_number                 60015
  contract_number_addition        83
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2215
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 5000,
                                      cycle: Contract::Payment::MONTHLY)] }
  after_create do |c|
    c.contractor_bank_account = Fabricate(:bank_account_mustermann, holder: 'hell & warm Forstenried GmbH', owner: c.customer)
    c.save
  end
end




################
### LCP Sulz ###
################



Fabricator :lptc_hafi, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        1
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1
  renewable_energy_law_taxation   Contract::Base::REDUCED
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 0,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_hubv, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        2
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2102
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 5500,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_mape, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        3
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 4603
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 11000,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_hafi2, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  enddate = Date.new(2016, 10, 31)
  contract_number                 60042
  contract_number_addition        4
  begin_date                      begindate
  end_date                        enddate
  signing_date                    signingdate
  forecast_kwh_pa                 1
  renewable_energy_law_taxation   Contract::Base::REDUCED
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: enddate,
                                      price_cents: 0,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_musc, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        5
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 11095
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 23000,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_viwe, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        6
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1972
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 9900,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_reho, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        7
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 3706
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 11200,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_pewi, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 11, 1)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        9
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 3693
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 6000,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :lptc_saba, from: :localpool_power_taker_contract do
  begindate = Date.new(2017, 3, 1)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        10
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 3090
  renewable_energy_law_taxation   Contract::Base::FULL
  tariffs                         { [Fabricate.build(:tariff_sulz)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 6600,
                                      cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :osc_saba, from: :other_supplier_contract do
  begindate = Date.new(2016, 8, 4)
  enddate = Date.new(2017, 2, 28)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 60042
  contract_number_addition        8
  begin_date                      begindate
  end_date                        enddate
  signing_date                    signingdate
  forecast_kwh_pa                 2500
  renewable_energy_law_taxation   Contract::Base::FULL
end

# == LCP Contracts Sulz == #

Fabricator :lpc_sulz, from: :localpool_processing_contract do
  begindate = Date.new(2016, 8, 4)
  customer_number '40361/1'
  contract_number                 60042
  contract_number_addition        0
  begin_date      begindate
  signing_date    begindate - 2.months
  tariffs         { [Fabricate.build(:tariff,
                      name: 'localpool_processing_standard',
                      begin_date: begindate,
                      end_date: begindate,
                      energyprice_cents_per_kwh: 0,
                      baseprice_cents_per_month: 100000)] }
  payments        { [Fabricate.build(:payment,
                      begin_date: begindate,
                      end_date: begindate,
                      price_cents: 100000,
                      cycle: Contract::Payment::ONCE),
                    Fabricate.build(:payment,
                      begin_date: begindate,
                      end_date: begindate,
                      price_cents: 100000,
                      cycle: Contract::Payment::ONCE)] }
end

Fabricator :mpoc_sulz, from: :metering_point_operator_contract do
  begindate = Date.new(2016, 8, 4)
  metering_point_operator_name  'buzzn systems UG'
  customer_number               '40361/1'
  contract_number               90067
  contract_number_addition      0
  begin_date                    begindate
  signing_date                  begindate - 2.months
  contractor                    { Organization.buzzn_systems }
  tariffs                       { [Fabricate.build(:tariff,
                                    name: 'metering_standard',
                                    begin_date: begindate,
                                    end_date: nil,
                                    energyprice_cents_per_kwh: 0,
                                    baseprice_cents_per_month: 30000)] }
  payments                      { [Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate,
                                    price_cents: 30000,
                                    cycle: Contract::Payment::ONCE),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate,
                                    price_cents: 30000,
                                    cycle: Contract::Payment::ONCE),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: nil,
                                    price_cents: 55000,
                                    cycle: Contract::Payment::MONTHLY),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate.end_of_year,
                                    price_cents: 55000,
                                    cycle: Contract::Payment::MONTHLY)] }
end

Fabricator :osc_sulz, from: :other_supplier_contract do
  begindate = Date.new(2016, 8, 4)
  signingdate = Date.new(2016, 7, 1)
  contract_number                 89776779
  contract_number_addition        345
  begin_date                      begindate
  signing_date                    signingdate
  forecast_kwh_pa                 5000
  renewable_energy_law_taxation   Contract::Base::FULL
  contractor                      { Organization.gemeindewerke_peissenberg || Fabricate(:gemeindewerke_peissenberg) }
end
