module SampleData::PTContractFactory

  class << self

    def create(attrs = {})
      contract = create_contract(attrs.except(:register))
      link_register(contract, attrs[:register])
      create_roles(contract)
      contract
    end

    private

    def create_contract(attrs)
      all_attrs = attrs.reverse_merge(default_attrs)
      if all_attrs.delete(:gap_contract)
        FactoryGirl.create(:contract, :localpool_gap, all_attrs.merge(gap_contract_customer_and_contractor))
      elsif attrs.key?(:customer)
        all_attrs.reverse_merge!(contractor: localpool.owner)
        FactoryGirl.create(:contract, :localpool_powertaker, all_attrs)
      else
        FactoryGirl.create(:contract, :localpool_third_party, all_attrs)
      end
    end

    def link_register(contract, register)
      contract.market_location.register = register if register
    end

    def create_roles(contract)
      person =
        if contract.customer.is_a?(Person)
          contract.customer
        elsif contract.customer.is_a?(Organization)
          contract.customer.contact
        end
      if person
        person.add_role(Role::GROUP_MEMBER, localpool)
        person.add_role(Role::CONTRACT, contract)
      end
    end

    def localpool
      SampleData.localpools.people_power
    end

    def default_attrs
      {
        localpool:  localpool,
        begin_date: localpool.start_date,
        tariffs:    SampleData.localpools.people_power.tariffs.where(name: 'Hausstrom - Standard')
      }
    end

    def gap_contract_customer_and_contractor
      {
        contractor: localpool.owner,
        customer: localpool.gap_contract_customer
      }
    end

  end

end

SampleData.contracts = OpenStruct.new

# FIXME: when https://goo.gl/6pzpFd is implemented, assign the grid in/out registers correctly
SampleData.contracts.mpo = create(:contract, :metering_point_operator,
  localpool: SampleData.localpools.people_power,
  customer: SampleData.localpools.people_power.owner,
  contractor: Organization.buzzn,
  payments: [build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')]
                                 )

SampleData.contracts.lpp = create(:contract, :localpool_processing,
  localpool: SampleData.localpools.people_power,
  customer: SampleData.localpools.people_power.owner,
  contractor: Organization.buzzn,
  payments: [build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')],
  tariffs: [
    build(:tariff, name: 'Standard', energyprice_cents_per_kwh: 28.9, group: SampleData.localpools.people_power),
    build(:tariff, name: 'Reduziert', energyprice_cents_per_kwh: 25.9, group: SampleData.localpools.people_power)
  ]
                                 )

SampleData.contracts.pt1 = SampleData::PTContractFactory.create(
  customer: SampleData.persons.pt1,
  payments: [
    build(:payment, price_cents: 55_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.apartment_1
)

SampleData.contracts.pt2 = SampleData::PTContractFactory.create(
  customer: SampleData.persons.pt2,
  payments: [
    build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.apartment_2
)

# terminated gap contract
SampleData.contracts.pt3gap = SampleData::PTContractFactory.create(
  gap_contract: true,
  termination_date: Date.today,
  end_date: Date.today + 1.month,
  market_location: SampleData.market_locations.apartment_3
)

SampleData.contracts.pt3 = SampleData::PTContractFactory.create(
  begin_date: Date.today + 1.month,
  customer: SampleData.persons.pt3,
  payments: [
    build(:payment, price_cents: 67_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.apartment_3
)
SampleData.contracts.pt3.customer.add_role(Role::GROUP_ENERGY_MENTOR, SampleData.contracts.pt3.localpool)

SampleData.contracts.pt4 = SampleData::PTContractFactory.create(
  begin_date: Date.new(2017, 2, 1),
  termination_date: Date.yesterday,
  end_date: Date.today + 1.month,
  customer: SampleData.persons.pt4,
  payments: [
   build(:payment, price_cents: 53_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.apartment_4
)

# terminated gap contract
SampleData.contracts.pt4gap = SampleData::PTContractFactory.create(
  gap_contract: true,
  termination_date: SampleData.contracts.pt4.begin_date,
  end_date: SampleData.contracts.pt4.begin_date,
  market_location: SampleData.market_locations.apartment_4
)

# beendet, Auszug
SampleData.contracts.pt5a = SampleData::PTContractFactory.create(
  termination_date: Date.new(2017, 3, 10),
  end_date: Date.new(2017, 4, 1),
  customer: SampleData.persons.pt5a,
  market_location: SampleData.market_locations.apartment_5,
  payments: [
    build(:payment, price_cents: 45_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
)

# Leerstand
SampleData.contracts.pt5_empty = SampleData::PTContractFactory.create(
  gap_contract: true,
  begin_date: SampleData.contracts.pt5a.end_date,
  termination_date: Date.new(2017, 4, 30),
  end_date: Date.new(2017, 5, 1),
  market_location: SampleData.market_locations.apartment_5
)

# zieht ein
SampleData.contracts.pt5b = SampleData::PTContractFactory.create(
  begin_date: Date.new(2017, 5, 1),
  customer: SampleData.persons.pt5b,
  market_location: SampleData.market_locations.apartment_5
)

# Drittlieferant
SampleData.contracts.pt6 = SampleData::PTContractFactory.create(
  market_location: SampleData.market_locations.apartment_6
)

# Drittlieferant, vor Wechsel zu people power
SampleData.contracts.pt7a = SampleData::PTContractFactory.create(
  termination_date: Date.new(2017, 2, 15),
  end_date: Date.new(2017, 3, 1),
  market_location: SampleData.market_locations.apartment_7
)

# Drittlieferant, nach Wechsel zu people power
SampleData.contracts.pt7b = SampleData::PTContractFactory.create(
  begin_date: SampleData.contracts.pt7a.end_date,
  customer: SampleData.persons.pt7,
  market_location: SampleData.market_locations.apartment_7
)

# English language speaker
SampleData.contracts.pt8 = SampleData::PTContractFactory.create(
  customer: SampleData.persons.pt8,
  market_location: SampleData.market_locations.apartment_8
)

# A regular move out/move in. This will result in a closed billing for the first contract.
SampleData.contracts.pt9a = SampleData::PTContractFactory.create(
  end_date: Date.new(Date.today.year, 2, 1),
  customer: SampleData.persons.pt9a,
  market_location: SampleData.market_locations.apartment_9
)
SampleData.contracts.pt9b = SampleData::PTContractFactory.create(
  begin_date: SampleData.contracts.pt9a.end_date,
  customer: SampleData.persons.pt9b,
  market_location: SampleData.market_locations.apartment_9
)

# a substitute meter/register
SampleData.contracts.pt10 = SampleData::PTContractFactory.create(
  customer: SampleData.persons.pt10,
  market_location: SampleData.market_locations.apartment_10
)

# Allgemeinstrom (Hausbeleuchtung etc.)
SampleData.contracts.common_consumption = SampleData::PTContractFactory.create(
  contractor: SampleData.localpools.people_power.owner,
  customer: SampleData.localpools.people_power.owner,
  market_location: SampleData.market_locations.common_consumption
)

SampleData.contracts.ecar = SampleData::PTContractFactory.create(
  contractor: SampleData.localpools.people_power.owner,
  customer: SampleData.localpools.people_power.owner,
  market_location: SampleData.market_locations.ladestation_eauto
)
