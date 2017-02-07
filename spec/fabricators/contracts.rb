# coding: utf-8
Fabricator :payment do
  begin_date   { FFaker::Time.date }
  price_cents { rand(100) + 1 }
end

Fabricator :tariff do
  name                      { FFaker::Name.name }
  begin_date                { FFaker::Time.date }
  energyprice_cents_per_kwh { rand(100) + 1 }
  baseprice_cents_per_month { rand(10) + 1 }
end


# == Metering Point Operator Contract ==

Fabricator :metering_point_operator_contract do
  metering_point_operator_name { FFaker::Name.name }
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  customer                 { Fabricate(:contracting_party,
                                       user: Fabricate(:user)) }
  contractor               { Organization.discovergy.contracting_party }
end

Fabricator :metering_point_operator_contract_of_localpool, from: :metering_point_operator_contract do
  localpool { Fabricate(:localpool) }
end

Fabricator :metering_point_operator_contract_of_register, from: :metering_point_operator_contract do
  register { Fabricate(:meter).registers.first }
end

Fabricator :metering_point_operator_contract_of_localpool_for_organization, from: :metering_point_operator_contract_of_localpool do
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end

Fabricator :metering_point_operator_contract_of_register_for_organization, from: :metering_point_operator_contract_of_register do
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end

# == Power Taker Contract ==

Fabricator :power_taker_contract do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:contracting_party,
                                       user: Fabricate(:user)) }
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
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end

Fabricator :power_taker_contract_old_contract_for_organization, from: :power_taker_contract_old_contract do
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end

# == Power Giver Contract ==

Fabricator :power_giver_contract do
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
  customer                 { Fabricate(:contracting_party,
                                       user: Fabricate(:user)) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
end

Fabricator :power_giver_contract_for_organization, from: :power_giver_contract do
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end

# == Localpool Power Taker Contract ==

Fabricator :localpool_power_taker_contract do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) }
  customer                 { Fabricate(:contracting_party,
                                       user: Fabricate(:user)) }
  register                 { Fabricate(:input_register,
                                       group: Fabricate(:localpool),
                                       meter: Fabricate.build(:meter),
                                       address: Fabricate.build(:address) ) }
  renewable_energy_law_taxation { FFaker::Boolean.maybe }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
end

Fabricator :localpool_power_taker_contract_for_organization, from: :localpool_power_taker_contract do
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end


# == Localpool Processing Contract ==

Fabricator :localpool_processing_contract do
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { Fabricate(:user) }
  terms_accepted           true
  power_of_attorney        true
  begin_date               { FFaker::Time.date }
  signing_date             { FFaker::Time.date }
  forecast_kwh_pa          { rand(100) + 1 }
  customer                 { Fabricate(:contracting_party,
                                       user: Fabricate(:user)) }
  localpool                { Fabricate(:localpool) }
  first_master_uid         { sequence(:uid, 90688251510000000000002677114) }
  tariffs                  { [Fabricate.build(:tariff)] }
  payments                 { [Fabricate.build(:payment)] }
end

Fabricator :localpool_processing_contract_for_organization, from: :localpool_processing_contract do
  customer     { Fabricate(:contracting_party,
                           legal_entity: :company,
                           organization: Fabricate(:other_organization),
                           user: Fabricate(:user)) }
end


Fabricator :mpoc_buzzn_metering, from: :metering_point_operator_contract do
  contractor    { Organization.buzzn_energy.contracting_party }
  tariffs       { [Fabricate.build(:tariff)] }
  payments      { [Fabricate.build(:payment)] }
  username      'team@localpool.de'
  password      'Zebulon_4711'
end


# real stuff

Fabricator :mpoc_justus, from: :metering_point_operator_contract do
  contractor    { Organization.discovergy.contracting_party }
  username      'justus@buzzn.net'
  password      'PPf93TcR'
end

Fabricator :mpoc_stefan, from: :metering_point_operator_contract do
  contractor     { Organization.discovergy.contracting_party }
  username       'stefan@buzzn.net'
  password       '19200buzzn'
  register       { Fabricate(:easymeter_1024000034).registers.first }
end

Fabricator :mpoc_karin, from: :metering_point_operator_contract do
  contractor    { Organization.discovergy.contracting_party }
  customer      { Fabricate(:karin).contracting_parties.first }
  username      'karin.smith@solfux.de'
  password      '19200buzzn'
  register      { Fabricate(:easymeter_60051431).output_register }
  status        :running
  after_create do |c|
    karin = c.customer.user
    karin.add_role :member, c.register
    karin.add_role :manager, c.register
  end
end


Fabricator :mpoc_christian, from: :metering_point_operator_contract do
  contractor    { Organization.discovergy.contracting_party }
  username      'christian@buzzn.net'
  password      'Roentgen11smartmeter'
  register      { Fabricate(:easymeter_60138988).input_register }
end

Fabricator :mpoc_philipp, from: :metering_point_operator_contract do
  contractor    { Organization.discovergy.contracting_party }
  username      'info@philipp-osswald.de'
  password      'Null8fünfzehn'
  register      { Fabricate(:easymeter_60009269).input_register }
end

# TODO needs register
Fabricator :mpoc_thomas, from: :metering_point_operator_contract do
  contractor    { Organization.discovergy.contracting_party }
  username      'thomas@buzzn.net'
  password      'DSivKK1980'
end

# thomas wohnung
Fabricator :mpoc_ferraris_0001_amperix, from: :metering_point_operator_contract do
  contractor    { Organization.mysmartgrid.contracting_party }
  username      '6ed89edf81be48586afc19f9006feb8b'
  password      '1a875e34e291c28db95ecbda015ad433'
  register      { Fabricate(:ferraris_001_amperix).input_register }
end

# wogeno oberländerstr bhkw
Fabricator :mpoc_ferraris_0002_amperix, from: :metering_point_operator_contract do
  contractor     { Organization.mysmartgrid.contracting_party }
  username      '721bcb386c8a4dab2510d40a93a7bf66'
  password      '0b81f58c19135bc01420aa0120ae7693'
end
