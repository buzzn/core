class RenameMeterRegisterColumns < ActiveRecord::Migration
  def change
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
    add_column :meters, :direction_number, :string

    add_column :meters, :build_year_ng, :integer
    Meter::Base.reset_column_information
    Meter::Base.all.each do |meter|
      meter.build_year_ng = meter.build_year.year if meter.build_year
    end
    remove_column :meters, :build_year
    rename_column :meters, :build_year_ng, :build_year
    remove_column :registers, :forecast_kwh_pa

    remove_column :meters, :remote_readout

    rename_column :meters, :metering_type, :edifact_metering_type
    rename_column :meters, :section, :edifact_section
    rename_column :meters, :tariff, :edifact_tariff
    rename_column :meters, :measurement_capture, :edifact_measurement_method
    rename_column :meters, :mounting_method, :edifact_mounting_method
    rename_column :meters, :meter_size, :edifact_meter_size
    rename_column :meters, :voltage_level, :edifact_voltage_level
    rename_column :meters, :cycle_interval, :edifact_cycle_interval
    rename_column :meters, :data_logging, :edifact_data_logging
    add_column :meters, :sent_data_dso, :date
    
    Meter::Base.reset_column_information
    Meter::Base.all.each do |meter|
      meter.sent_data_dso = DataTime.new if meter.send_data_dso
    end
    remove_column :meters, :send_data_dso
    remove_column :meters, :data_provider_name
    rename_column :meters, :calibrated_till, :calibrated_until

    Register::Base.reset_column_information
    Broker::Base.reset_column_information

    Meter::Base.all.each do |meter|
      meter.converter_constant = meter.main_equipment.converter_constant if meter.main_equipment
    end

    drop_table :equipment
  end
end
