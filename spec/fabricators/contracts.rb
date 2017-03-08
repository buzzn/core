# coding: utf-8
Fabricator :payment, class_name: Contract::Payment do
  begin_date   { FFaker::Time.date }
  price_cents { rand(100) + 1 }
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


# == Metering Point Operator Contract ==

Fabricator :metering_point_operator_contract, class_name: Contract::MeteringPointOperator do
  metering_point_operator_name { FFaker::Name.name }
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  customer                 { Fabricate(:user) }
  contractor               { Organization.discovergy }
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

# == Power Taker Contract ==

Fabricator :power_taker_contract, class_name: Contract::PowerTaker do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:user) }
  register                 { Fabricate(:input_register,
                                       meter: Fabricate.build(:meter),
                                       address: Fabricate.build(:address) ) }
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
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  confirm_pricing_model    true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  register                 { Fabricate(:output_register,
                                       meter: Fabricate.build(:meter),
                                       address: Fabricate.build(:address) ) }
  customer                 { Fabricate(:user) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
end

Fabricator :power_giver_contract_for_organization, from: :power_giver_contract do
  customer     { Fabricate(:other_organization) }
end

# == Localpool Power Taker Contract ==

Fabricator :localpool_power_taker_contract, class_name: Contract::LocalpoolPowerTaker do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:user) }
  contractor               { Fabricate(:user) }
  register                 { Fabricate(:input_register,
                                       group: Fabricate(:localpool),
                                       meter: Fabricate.build(:meter),
                                       address: Fabricate.build(:address) ) }
  renewable_energy_law_taxation { FFaker::Boolean.maybe }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
end

Fabricator :localpool_power_taker_contract_for_organization, from: :localpool_power_taker_contract do
  customer     { Fabricate(:other_organization) }
end


# == Localpool Processing Contract ==

Fabricator :localpool_processing_contract, class_name: Contract::LocalpoolProcessing do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:user) }
  localpool                { Fabricate(:localpool) }
  first_master_uid         { sequence(:uid, 90688251510000000000002677114) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
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
  status        :running
  after_create do |c|
    karin = c.customer
    karin.add_role :member, c.register
    karin.add_role :manager, c.register
  end
end

# == Localpool Contracts for Mehrgenerationenplatz Forstenried ==

Fabricator :lpc_forstenried, from: :localpool_processing_contract do
  begindate = Date.new(2014, 12, 01)
  customer_number '40021/1'
  contract_number '60015'
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
                      cycle: 'once',
                      source: 'calculated'),
                    Fabricate.build(:payment,
                      begin_date: begindate,
                      end_date: begindate,
                      price_cents: 100000,
                      cycle: 'once',
                      source: 'transferred')] }
end

Fabricator :mpoc_forstenried, from: :metering_point_operator_contract do
  begindate = Date.new(2014, 12, 01)
  metering_point_operator_name  'buzzn systems UG'
  customer_number               '40021/1'
  contract_number               '90041'
  begin_date                    begindate
  signing_date                  begindate - 2.months
  contractor                    { Organization.buzzn_systems }
  tariffs                       { [Fabricate.build(:tariff,
                                    name: 'localpool_processing_standard',
                                    begin_date: begindate,
                                    end_date: nil,
                                    energyprice_cents_per_kwh: 0,
                                    baseprice_cents_per_month: 30000)] }
  payments                      { [Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate,
                                    price_cents: 30000,
                                    cycle: 'once',
                                    source: 'calculated'),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate,
                                    price_cents: 30000,
                                    cycle: 'once',
                                    source: 'transferred'),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: nil,
                                    price_cents: 55000,
                                    cycle: 'monthly',
                                    source: 'calculated'),
                                  Fabricate.build(:payment,
                                    begin_date: begindate,
                                    end_date: begindate.end_of_year,
                                    price_cents: 55000,
                                    cycle: 'monthly',
                                    source: 'transferred'),
                                  Fabricate.build(:payment,
                                    begin_date: begindate.next_year.beginning_of_year,
                                    end_date: begindate.next_year.end_of_year,
                                    price_cents: 55000,
                                    cycle: 'monthly',
                                    source: 'transferred')] }
end

# == Localpool Power Taker Contracts for Mehrgenerationenplatz Forstenried ==

Fabricator :lptc_markus_becher, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/1'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1495
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 3500,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_inge_brack, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/2'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1480
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 3400,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_peter_brack, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/3'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 651
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 1600,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_annika_brandl, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/4'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2275
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 5100,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_gudrun_brandl, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 15)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/5'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 621
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 1600,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_martin_braeunlich, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/6'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1000
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 2400,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_daniel_bruno, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 1)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/7'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2800
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 6200,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_zubair_butt, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/8'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 4000
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 8800,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_maria_cerghizan, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/9'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 1000
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 2400,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_stefan_csizmadia, from: :localpool_power_taker_contract do
  begindate = Date.new(2015, 1, 15)
  signingdate = Date.new(2014, 12, 01)
  contract_number                 '60015/10'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 900
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 2200,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_patrick_fierley, from: :localpool_power_taker_contract do
  begindate = Date.new(2014, 12, 15)
  signingdate = Date.new(2014, 12, 01)
  cancellationdate = Date.new(2016, 01, 01)
  enddate = Date.new(2016, 04, 28)
  contract_number                 '60015/11'
  begin_date                      begindate
  end_date                        enddate
  signing_date                    signingdate
  cancellation_date               cancellationdate
  forecast_kwh_pa                 1800
  renewable_energy_law_taxation   'full'
  status                          :expired
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: enddate,
                                      price_cents: 4100,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

Fabricator :lptc_rafal_jaskolka, from: :localpool_power_taker_contract do
  begindate = Date.new(2016, 05, 01)
  signingdate = Date.new(2016, 02, 01)
  contract_number                 '60015/83'
  begin_date                      begindate
  end_date                        nil
  signing_date                    signingdate
  forecast_kwh_pa                 2215
  renewable_energy_law_taxation   'full'
  status                          :running
  tariffs                         { [Fabricate.build(:tariff_forstenried)] }
  payments                        { [Fabricate.build(:payment,
                                      begin_date: begindate,
                                      end_date: nil,
                                      price_cents: 5000,
                                      cycle: 'monthly',
                                      source: 'calculated')] }
end

