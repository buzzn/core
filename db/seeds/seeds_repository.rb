# Generates and caches the factories/DB records that we need to access globally.
module SeedsRepository
  include FactoryGirl::Syntax::Methods

  class << self

    def persons
      @persons ||= OpenStruct.new(
        wolfgang: create(:person, :with_bank_account, :wolfgang),
        pt1:  create(:person, :with_bank_account, first_name: 'Sabine',    last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
        pt2:  create(:person, :with_bank_account, first_name: 'Claudia',   last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
        pt3:  create(:person, :with_bank_account, first_name: 'Bernd',     last_name: 'Powertaker3'),
        pt4:  create(:person, :with_bank_account, first_name: 'Karlheinz', last_name: 'Powertaker4'),
        pt5a: create(:person, :with_bank_account, first_name: 'Sylvia',    last_name: 'Powertaker5a (zieht ein)', prefix: 'F'),
        pt5b: create(:person, :with_bank_account, first_name: 'Fritz',     last_name: 'Powertaker5b (zieht aus)'),
        pt6:  create(:person, :with_bank_account, first_name: 'Horst',     last_name: 'Powertaker6 (drittbeliefert)'),
        pt7:  create(:person, :with_bank_account, first_name: 'Karla',     last_name: 'Powertaker7 (Mentor)', prefix: 'F'),
        pt8:  create(:person, :with_bank_account, first_name: 'Geoffrey',  last_name: 'Powertaker8', preferred_language: 'english'),
        pt9:  create(:person, :with_bank_account, first_name: 'Justine',   last_name: 'Powertaker9', prefix: 'F'),
        pt10: create(:person, :with_bank_account, first_name: 'Mohammed',  last_name: 'Powertaker10')
      )
    end

    def localpools
      @localpools ||= OpenStruct.new(
       people_power: create(:localpool, :people_power, owner: SeedsRepository.persons.wolfgang)
      )
    end

    def meters
      @meters ||= OpenStruct.new(
        grid: create(:meter_real, :two_way, group: SeedsRepository.localpools.people_power)
      )
    end
  end
end
