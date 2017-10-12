require_relative 'seeds_repository'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

puts "seeds: loading sample data"

FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions
include FactoryGirl::Syntax::Methods

# Call the buzzn operator once so it is generated.
SeedsRepository.persons.buzzn_operator

def localpool_contract(attrs = {})
  localpool = SeedsRepository.localpools.people_power
  factory_attributes = attrs.except(:register_readings).merge(localpool: localpool).reverse_merge(contractor: localpool.owner)
  contract = create(:contract, :localpool_powertaker, factory_attributes)
  contract.register.readings = attrs[:register_readings] unless attrs.fetch(:register_readings, []).empty?
  if contract.customer.is_a?(Person) # TODO: clarify what to do when it's an Organization?
    contract.customer.add_role(Role::GROUP_MEMBER, localpool)
    contract.customer.add_role(Role::CONTRACT, contract)
  end
  contract
end

contracts = {}

contracts[:pt1] = localpool_contract(
  customer: SeedsRepository.persons.pt1,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 55_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

contracts[:pt2] = localpool_contract(
  customer: SeedsRepository.persons.pt2,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

contracts[:pt3] = localpool_contract(
  signing_date: (Date.today - 5.days),
  begin_date: Date.today + 1.month,
  status: Contract::Base.statuses[:onboarding],
  customer: SeedsRepository.persons.pt3,
  register_readings: [
    build(:reading, :setup, date: '2017-10-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 67_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

contracts[:pt4] = localpool_contract(
  signing_date: Date.parse("2017-1-10"),
  begin_date: Date.parse("2017-2-1"),
  cancellation_date: Date.yesterday,
  end_date: Date.today + 1.month,
  status: Contract::Base.statuses[:terminated],
  customer: SeedsRepository.persons.pt4,
  register_readings: [
    build(:reading, :setup, date: '2017-02-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 53_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

# beendet, Auszug
contracts[:pt5a] = localpool_contract(
  cancellation_date: Date.parse("2017-3-10"),
  end_date: Date.parse("2017-4-1"),
  status: Contract::Base.statuses[:ended],
  customer: SeedsRepository.persons[:pt5a],
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 1_300_000, register: nil),
    build(:reading, :contract_change, date: '2017-04-01', raw_value: 1_765_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 45_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

# Leerstand
contracts[:pt5_empty] = localpool_contract(
  signing_date: contracts[:pt5a].cancellation_date,
  begin_date: contracts[:pt5a].end_date,
  cancellation_date: Date.parse("2017-4-30"),
  end_date: Date.parse("2017-5-1"),
  status: Contract::Base.statuses[:ended],
  register: contracts[:pt5a].register, # important !
  customer: SeedsRepository.organizations.property_management,
)

# zieht ein
contracts[:pt5b] = localpool_contract(
  signing_date: Date.parse("2017-4-10"),
  begin_date: Date.parse("2017-5-1"),
  register: contracts[:pt5a].register, # important !
  customer: SeedsRepository.persons[:pt5b],
)

# Drittlieferant
contracts[:pt6] = localpool_contract(contractor: SeedsRepository.organizations.third_party_supplier, customer: SeedsRepository.persons.pt6)

# Drittlieferant, vor Wechsel zu people power
contracts[:pt7a] = localpool_contract(
  cancellation_date: Date.parse("2017-2-15"),
  end_date: Date.parse("2017-3-1"),
  status: Contract::Base.statuses[:ended],
  contractor: SeedsRepository.organizations.third_party_supplier,
  customer: SeedsRepository.persons.pt7,
)
contracts[:pt7a].customer.add_role(Role::GROUP_ENERGY_MENTOR, contracts[:pt7a].localpool)

# Drittlieferant, nach Wechsel zu people power
contracts[:pt7b] = localpool_contract(
  signing_date: contracts[:pt7a].cancellation_date,
  begin_date: contracts[:pt7a].end_date,
  customer: SeedsRepository.persons.pt7,
  register: contracts[:pt7a].register, # important !
)

# English
contracts[:pt8] = localpool_contract(customer: SeedsRepository.persons.pt8)

# Two more powertakers to make them 10 ...
contracts[:pt9] = localpool_contract(customer: SeedsRepository.persons.pt9)
contracts[:pt10] = localpool_contract(customer: SeedsRepository.persons.pt10)

# Allgemeinstrom (Hausbeleuchtung etc.)
contracts[:common_consumption] = localpool_contract(
  contractor: SeedsRepository.localpools.people_power.owner,
  customer: SeedsRepository.localpools.people_power.owner,
  register: create(:register, :input, name: "Allgemeinstrom", group: SeedsRepository.localpools.people_power),
)

create(:meter_real, :two_way,
  group: SeedsRepository.localpools.people_power,
  registers: [
    create(:register, :grid_output,
      group: SeedsRepository.localpools.people_power,
      readings: [
        build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
        build(:reading, :regular, date: '2016-12-31', raw_value: 12_000_000, register: nil)
      ]
    ),
    create(:register, :grid_input,
      group: SeedsRepository.localpools.people_power,
      readings: [
        build(:reading, :setup, date: '2016-01-01', raw_value: 2_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
        build(:reading, :regular, date: '2016-12-31', raw_value: 66_000_000, register: nil)
      ]
    )
  ]
)

#
# Create other contracts for peoplepower group
#
# FIXME:
#  - contractor needs to be buzzn not generic org
#  - when https://goo.gl/6pzpFd is implemented, assign the grid in/out registers correctly
create(:contract, :metering_point_operator,
       localpool: SeedsRepository.localpools.people_power,
       customer: SeedsRepository.localpools.people_power.owner,
       payments: [
         build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
       ]
)

#
# More registers (without powertakers & contracts)
#
registers = {}

registers[:ecar] = create(:register, :input, name: 'Ladestation eAuto', label: Register::Base.labels[:other],
  group: SeedsRepository.localpools.people_power,
  devices: [ create(:device, :ecar, commissioning: '2017-04-10', register: nil) ]
)

registers[:bhkw] = create(:register, :production_bhkw,
  group: SeedsRepository.localpools.people_power,
  devices: [ create(:device, :bhkw, commissioning: '1995-01-01', register: nil) ]
)

registers[:pv] = create(:register, :production_pv,
  group: SeedsRepository.localpools.people_power,
  devices: [ create(:device, :pv, commissioning: '2017-04-10', register: nil) ]
)

FactoryGirl.create(:organization, :contracting_party,
                   name: 'Buzzn GmbH',
                   description: 'Purveyor of peoplepower since 2009',
                   slug: 'buzzn',
                   email: 'dev@buzzn.net',
                   phone: '089 / 32 16 8',
                   website: 'www.buzzn.net'
)
FactoryGirl.create(:organization, :transmission_system_operator,
                   name: '50Hertz Transmission GmbH',
                   slug: '50hertz',
                   edifactemail: 'roman.schuelke@50hertz.com',
                   phone: '+49 30 51503782',
                   fax: '+49 30 51504511',
                   website: 'http://www.50hertz.com/de',
                   market_place_id: '9911845000009'
)
FactoryGirl.create(:organization, :transmission_system_operator,
                   name: 'Tennet TSO GmbH',
                   slug: 'tennet',
                   edifactemail: 'biko-bka@tennet.eu',
                   phone: '+49 921 507404575',
                   fax: '+49 921 507404566',
                   website: 'https://www.tennet.eu/de', market_place_id: '4033872000058'
)
FactoryGirl.create(:organization, :transmission_system_operator,
                   name: 'Amprion GmbH',
                   slug: 'amprion',
                   edifactemail: 'gpke@amprion.net',
                   phone: '+49 231 5849 12502',
                   fax: '+49 231 5849 14509',
                   website: 'https://www.amprion.net',
                   market_place_id: '4045399000077'
)
FactoryGirl.create(:organization, :transmission_system_operator,
                   name: 'TransnetBW GmbH',
                   slug: 'transnetbw',
                   edifactemail: 'bilanzkreise@transnetbw.de',
                   phone: '+49 711 21858 3706',
                   fax: '+49 711 21858 4413',
                   website: 'https://www.transnetbw.de/de',
                   market_place_id: '9911835000001'
)
FactoryGirl.create(:organization, :distribution_system_operator,
                   name: 'E.ON Netz GmbH',
                   slug: 'eon-netz',
                   website: 'https://www.eon.com'
)
FactoryGirl.create(:organization, :distribution_system_operator,
                   name: 'Stadtwerke Augsburg GmbH',
                   slug: 'sw-augsburg',
                   website: 'www.sw-augsburg.de'
)
FactoryGirl.create(:organization, :distribution_system_operator,
                   name: 'SWM Infrastruktur GmbH & Co. KG',
                   slug: 'swm',
                   edifactemail: 'netznutzung@swm.de',
                   phone: '+49 89 2361 4644',
                   fax: '+49 89 2361 4699',
                   website: 'http://www.swm-infrastruktur.de',
                   market_place_id: '9907248000001'
)
FactoryGirl.create(:organization, :distribution_system_operator,
                   name: 'Bayernwerk Netz GmbH',
                   slug: 'bayernwerk-netz',
                   edifactemail: 'netz-msb-mdl@bayernwerk.de',
                   phone: '+49 941 2017128',
                   fax: '+49 941 2017113',
                   website: 'http://www.bayernwerk-netz.de',
                   market_place_id: '9901068000001'
)
FactoryGirl.create(:organization, :metering_point_operator,
                   name: 'Discovergy',
                   description: 'MPO of EasyMeters',
                   slug: 'discovergy',
                   website: 'https://discovergy.com'
)
FactoryGirl.create(:organization, :metering_point_operator,
                   name: 'MySmartGrid',
                   description: 'Fraunhofer Institut',
                   slug: 'mysmartgrid',
                   website: 'https://www.itwm.fraunhofer.de/en/departments/hpc/green-by-it/mySmartGrid-energy-savings.html'
)
FactoryGirl.create(:organization, :electricity_supplier,
                   name: 'Buzzn GmbH (Lieferant)',
                   description: 'Buzzn community power (performed by S-Hall)',
                   slug: 'buzzn-energy',
                   phone: '089 / 32 16 8',
                   website: 'www.buzzn.net',
                   market_place_id: '9905229000008',
                   energy_classifications: [ create(:energy_classification, :buzzn_energy) ]
)
FactoryGirl.create(:organization, :electricity_supplier,
                   name: 'Germany',
                   description: 'used for energy mix \'Germany\'',
                   slug: 'germany',
                   energy_classifications: [ create(:energy_classification, :germany) ]
)
FactoryGirl.create(:organization, :electricity_supplier,
                   name: 'E.ON'
)
FactoryGirl.create(:organization, :electricity_supplier,
                   name: 'RWE'
)
FactoryGirl.create(:organization, :electricity_supplier,
                   name: 'Vattenfall'
)
FactoryGirl.create(:organization, :electricity_supplier,
                   name: 'EnBW'
)
FactoryGirl.create(:organization, :other, :with_bank_account,
                   name: 'hell & warm Forstenried GmbH',
                   slug: 'hell-warm',
                   email: 'xxx@info.de',
                   phone: '089/89057180', mode: 'other'
)

# FIXME: fails with validation 'Gültigkeitsprüfung ist fehlgeschlagen: Contractor must be buzzn-systems'
# create(:contract, :localpool_processing,
#        localpool: SeedsRepository.localpools.people_power,
#        customer: SeedsRepository.localpools.people_power.owner,
#        contractor: SeedsRepository.organizations.buzzn_systems
# )
