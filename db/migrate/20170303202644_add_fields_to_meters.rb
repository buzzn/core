class AddFieldsToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :section, :string
    add_column :meters, :metering_point_type, :string
    add_column :meters, :voltage_level, :string
    add_column :meters, :cycle_interval, :string
    add_column :meters, :send_data_dso, :boolean
    add_column :meters, :remote_readout, :boolean
    add_column :meters, :tariff, :string
    add_column :meters, :direction, :string
    add_column :meters, :data_logging, :string
    add_column :meters, :manufacturer_number, :string
    add_column :meters, :converter_constant, :integer
    add_column :meters, :data_provider_name, :string
    remove_column :meters, :online, :boolean
    remove_column :meters, :pull_readings, :boolean
    remove_column :meters, :init_first_reading, :boolean
  end
end
