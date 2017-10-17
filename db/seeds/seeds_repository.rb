# Generates and caches the factories/DB records that we need to access globally.
module SeedsRepository
  include FactoryGirl::Syntax::Methods

  class << self

    def persons
      @persons ||= OpenStruct.new(
        buzzn_operator: create(:person, :with_self_role, :with_account,
                               first_name: 'Philipp',
                               last_name: 'Operator',
                               email: 'dev+op@buzzn.net',
                               roles: { Role::BUZZN_OPERATOR => nil }),
        group_owner: person(:wolfgang),
        brumbauer:   person(first_name: 'Traudl', last_name: 'Brumbauer', prefix: 'F'),
        pt1:  person(first_name: 'Sabine', last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
        pt2:  person(first_name: 'Carla', last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
        pt3:  person(first_name: 'Bernd', last_name: 'Powertaker3'),
        pt4:  person(first_name: 'Karl', last_name: 'Powertaker4'),
        pt5a: person(first_name: 'Sylvia', last_name: 'Powertaker5a (zieht aus)', prefix: 'F'),
        pt5b: person(first_name: 'Fritz', last_name: 'Powertaker5b (zieht ein)'),
        pt6:  person(first_name: 'Horst', last_name: 'Powertaker6 (drittbeliefert)'),
        pt7:  person(first_name: 'Anna', last_name: 'Powertaker7 (Wechsel zu uns)', prefix: 'F'),
        pt8:  person(first_name: 'Sam',  last_name: 'Powertaker8', preferred_language: 'english'),
        pt9:  person(first_name: 'Justine', last_name: 'Powertaker9', prefix: 'F'),
        pt10: person(first_name: 'Mohammed', last_name: 'Powertaker10')
      )
    end

    def localpools
      @localpools ||= OpenStruct.new(
       people_power: create(:localpool, :people_power, owner: persons.group_owner,
                            admins: [ persons.brumbauer ],
                            # FIXME: to be renamed to group_tariff
                            prices: [
                              build(:price, name: "Hausstrom - Standard"),
                              build(:price, name: "Hausstrom - Reduziert", energyprice_cents_per_kilowatt_hour: 24.9),
                            ]
       )
      )
    end

    def organizations
      @organizations ||= OpenStruct.new(
        third_party_supplier: create(:organization, :contracting_party, name: 'Drittlieferant'),
        property_management: create(:organization, :contracting_party, name: 'Hausverwaltung Schneider (Leerstand)'),
        # FIXME this has been merged with buzzn_gmbh, adapt sample data accordingly.
        # buzzn: create(:organization, :metering_point_operator, name: 'Buzzn GmbH', slug: 'buzzn',
        #                       phone: '089 / 32 16 8', website: 'www.buzzn.net', market_place_id: '9910960000001')
      )
    end

    def contracts
      @contracts ||= OpenStruct.new()
    end

    private

    def person(attributes)
      create(:person, :with_bank_account, :with_self_role, :with_account, attributes)
    end
  end
end
