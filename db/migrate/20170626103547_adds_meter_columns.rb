class AddsMeterColumns < ActiveRecord::Migration
  def up
    rename_column :registers, :mode, :direction
    remove_column :registers, :is_dashboard_register
    remove_column :registers, :readable
    rename_column :registers, :min_watt, :observer_min_threshold
    rename_column :registers, :max_watt, :observer_max_threshold
    rename_column :registers, :observe, :observer_enabled
    rename_column :registers, :observe_offline, :observer_offline_monitoring
    rename_column :registers, :last_observed_timestamp, :last_observed
    rename_column :registers, :digits_before_comma, :pre_decimal_position
    rename_column :registers, :decimal_digits, :post_decimal_position
    rename_column :registers, :uid, :metering_point_id

    rename_column :meters, :manufacturer_product_serialnumber, :product_serialnumber
    remove_column :meters, :manufacturer_number
    rename_column :meters, :manufacturer_product_name, :product_name
    remove_column :meters, :image

    rename_column :meters, :ownership, :ownership_old
    rename_column :meters, :section, :section_old
    rename_column :meters, :manufacturer_name, :manufacturer_name_old

    create_enum :direction_number, *Meter::Real::DIRECTION_NUMBERS
    create_enum :section, *Meter::Base::SECTIONS
    create_enum :ownership, *Meter::Base::OWNERSHIPS

    create_enum :edifact_voltage_level, *Meter::Base::VOLTAGE_LEVELS
    create_enum :edifact_cycle_interval, *Meter::Base::CYCLE_INTERVALS
    create_enum :edifact_data_logging, *Meter::Base::DATA_LOGGINGS
    create_enum :edifact_measurement_method, *Meter::Base::MEASUREMENT_METHODS
    create_enum :edifact_meter_size, *Meter::Base::METER_SIZES
    create_enum :edifact_metering_type, *Meter::Base::METERING_TYPES
    create_enum :edifact_mounting_method, *Meter::Base::MOUNTING_METHODS
    create_enum :edifact_tariff, *Meter::Base::TARIFFS
    create_enum :manufacturer_name, *Meter::Real::MANUFACTURER_NAMES

    add_column :meters, :edifact_voltage_level, :edifact_voltage_level, index: true
    add_column :meters, :edifact_cycle_interval, :edifact_cycle_interval, index: true
    add_column :meters, :edifact_metering_type, :edifact_metering_type, index: true
    add_column :meters, :edifact_meter_size, :edifact_meter_size, index: true
    add_column :meters, :edifact_tariff, :edifact_tariff, index: true
    add_column :meters, :edifact_data_logging, :edifact_data_logging, index: true
    add_column :meters, :edifact_measurement_method, :edifact_measurement_method, index: true
    add_column :meters, :edifact_mounting_method, :edifact_mounting_method, index: true
    add_column :meters, :ownership, :ownership, index: true
    add_column :meters, :direction_number, :direction_number, index: true
    add_column :meters, :section, :section, index: true
    add_column :meters, :manufacturer_name, :manufacturer_name, index: true
    
    Meter::Base.all.each do |meter|
      if meter.voltage_level
        meter.send("#{meter.voltage_level}!")
      end
      if meter.cycle_interval
        meter.edifact_cycle_interval = meter.cycle_interval.upcase
      end
      if meter.metering_type
        meter.edifact_metering_type =
          case meter.metering_type
          when 'smart_meter'
            'EHZ'
          when 'analog_household_meter'
            'AHZ'
          when 'load_meter'
            'LAZ'
          when 'analog_ac_meter'
            'WSZ'
          when 'digital_household_meter'
            'EHZ'
          when 'maximum_meter'
            'MAZ'
          when 'individual_adjustment'
            'IVA'
          else
            raise meter.metering_type
          end
      end
      if meter.meter_size
        meter.send("#{meter.meter_size}!")
      end
      if meter.tariff
        meter.edifact_tariff =
          case meter.tariff
          when 'one_tariff'
            Meter::Base::SINGLE_TARIFF
          when 'two_tariffs'
            Meter::Base::DUAL_TARIFF
          when 'multiple_tariffs'
            Meter::Base::MULTI_TARIFF
          else
            raise meter.tariff
          end
      end
      if meter.data_logging
        meter.edifact_data_logging =
          case meter.data_logging
          when 'remote'
            Meter::Base::ELECTRONIC
          when 'manual'
            Meter::Base::ANALOG
          else
            raise meter.data_logging
          end
      end
      if meter.measurement_capture && meter.measurement_capture != 'some-capture'
        meter.edifact_measurement_method =
          case meter.measurement_capture
          when 'remote'
            Meter::Base::REMOTE
          when 'manual'
            Meter::Base::MANUAL
          else
            raise meter.measurement_capture
          end
      end
      if meter.mounting_method
        meter.edifact_mounting_method =
          case meter.mounting_method
          when 'plug_technique'
            Meter::Base::PLUG_TECHNIQUE
          when 'three_point_hanging'
            Meter::Base::THREE_POINT_MOUNTING 
          when 'cap_rail'
            Meter::Base::CAP_RAIL
          else
            raise meter.mounting_method
          end
      end
      if meter.ownership_old
        meter.ownership = meter.ownership_old.upcase
      end
      if meter.section_old
        meter.section =
          case meter.section_old
          when 'gas'
            Meter::Base::GAS
          when 'electricity'
            Meter::Base::ELECTRICITY
          else
            raise meter.measurement_method
          end
      end
      if meter.is_a? Meter::Real
        meter.one_way_meter! if meter.registers.size == 1
        meter.two_way_meter! if meter.registers.size == 2
        if meter.manufacturer_name_old
          meter.manufacturer_name = meter.manufacturer_name_old
        end
      end
      p meter.valid?
    end
    remove_column :meters, :ownership_old
    remove_column :meters, :section_old
    remove_column :meters, :manufacturer_name_old
  end

  def down
    raise 'not revertable'
  end
end
