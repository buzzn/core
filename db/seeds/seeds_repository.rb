# Generates and caches the factories/DB records that we need to access globally.
module SeedsRepository
  include FactoryGirl::Syntax::Methods

  class << self

    def persons
      @persons ||= OpenStruct.new(
        wolfgang: create(:person, :with_bank_account, :wolfgang)
      )
    end

    def localpools
      @localpools ||= OpenStruct.new(
       people_power: create(:localpool, :people_power, owner: persons.wolfgang)
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
  end
end
