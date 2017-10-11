# Generates and caches the factories/DB records that we need to access globally.
module SeedsRepository
  include FactoryGirl::Syntax::Methods

  class << self

    def persons
      @persons ||= OpenStruct.new(
        group_owner: person(:wolfgang),
        pt1:  person(first_name: 'Sabine', last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
        pt2:  person(first_name: 'Claudia', last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
        pt3:  person(first_name: 'Bernd', last_name: 'Powertaker3'),
        pt4:  person(first_name: 'Karlheinz', last_name: 'Powertaker4'),
        pt5a: person(first_name: 'Sylvia', last_name: 'Powertaker5a (zieht aus)', prefix: 'F'),
        pt5b: person(first_name: 'Fritz', last_name: 'Powertaker5b (zieht ein)'),
        pt6:  person(first_name: 'Horst', last_name: 'Powertaker6 (drittbeliefert)'),
        pt7:  person(first_name: 'Anna', last_name: 'Powertaker7 (Wechsel zu uns)', prefix: 'F'),
        pt8:  person(first_name: 'Geoffrey',  last_name: 'Powertaker8', preferred_language: 'english'),
        pt9:  person(first_name: 'Justine', last_name: 'Powertaker9', prefix: 'F'),
        pt10: person(first_name: 'Mohammed',last_name: 'Powertaker10')
      )
    end

    def localpools
      @localpools ||= OpenStruct.new(
       people_power: create(:localpool, :people_power, owner: persons.group_owner)
      )
    end

    def meters
      @meters ||= OpenStruct.new(
        grid: create(:meter_real, :two_way, group: localpools.people_power)
      )
    end

    def organizations
      @organizations ||= OpenStruct.new(
        third_party: create(:organization, name: 'Drittlieferant')
      )
    end

    def contracts
      @contracts ||= OpenStruct.new()
    end

    private

    def person(attributes)
      create(:person, :with_bank_account, :with_self_role, attributes)
    end
  end
end
