module Meter
  class Equipment < ActiveRecord::Base
    BUZZN_SYSTEMS = 'buzzn_systems'
    FOREIGN_OWNERSHIP = 'foreign_ownership'
    CUSTOMER = 'customer'
    LEASED = 'leased'
    BOUGHT = 'bought'

    class << self
      def ownership_constants
        @ownership ||= [BUZZN_SYSTEMS, FOREIGN_OWNERSHIP, CUSTOMER, LEASED, BOUGHT]
      end
    end

    belongs_to :meter, class_name: Meter::Base, foreign_key: 'meter_id'

    before_destroy :check_for_main_equipment

    validates :ownership, inclusion: {in: Meter::Equipment.ownership_constants}

    def check_for_main_equipment
      if meter.main_equipment == self
        meter.errors.add(:main_equipment, 'meter must have one main eqipment')
        raise Buzzn::NestedValidationError.new(:meter, meter.errors)
      end
    end
  end
end