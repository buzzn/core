module Meter
  class Equipment < ActiveRecord::Base
    belongs_to :meter, class_name: Meter::Base, foreign_key: 'meter_id'

    before_destroy :check_for_main_equipment

    def check_for_main_equipment
      if meter.main_equipment == self
        meter.errors.add(:main_equipment, 'meter must have one main eqipment')
        raise Buzzn::NestedValidationError.new(:meter, meter.errors)
      end
    end
  end
end