Fabricator(:new_meter_real, class_name: 'Meter::Real') do

  transient :registers

  group                        { Fabricate(:new_localpool) }
  manufacturer_name            Meter::Real.manufacturer_names[:easy_meter]
  product_name                 "R2D2"
  product_serialnumber         { sequence { |i| "7564" + sprintf("%04d", i) } }
  calibrated_until             Date.parse("2027-10-13")
  converter_constant           1
  ownership                    Meter::Real.ownerships[:buzzn_systems]
  direction_number             Meter::Real.direction_numbers[:one_way_meter]
  section                      Meter::Real.sections[:electricity]
  build_year                   2015
  sent_data_dso                Date.parse("2016-09-17")
  # edifact data
  edifact_metering_type        Meter::Real.edifact_metering_types[:digital_household_meter]
  edifact_meter_size           Meter::Real.edifact_meter_sizes[:edl40]
  edifact_measurement_method   Meter::Real.edifact_measurement_methods[:remote]
  edifact_mounting_method      Meter::Real.edifact_mounting_methods[:three_point_mounting]
  edifact_voltage_level        Meter::Real.edifact_voltage_levels[:low_level]
  edifact_cycle_interval       Meter::Real.edifact_cycle_intervals[:yearly]
  edifact_tariff               Meter::Real.edifact_tariffs[:single_tariff]
  edifact_data_logging         Meter::Real.edifact_data_loggings[:electronic]

  after_build do |meter, transients|
    # Add a register and prevent creating another meter (goes into endless loop) by passing in self.
    # This also allows passing registers to the factory like this
    # Fabricate(:new_meter_real, registers: [a_register_instance])
    registers = transients[:registers] || [Fabricate.build(:new_register_input, meter: meter)]
    meter.registers = registers
  end
end
