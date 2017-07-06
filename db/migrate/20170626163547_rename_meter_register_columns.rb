class RenameMeterRegisterColumns < ActiveRecord::Migration
  def change

    add_column :meters, :build_year_ng, :integer
    Meter::Base.reset_column_information
    Meter::Base.all.each do |meter|
      meter.update!(build_year_ng: meter.build_year.year) if meter.build_year
    end
    remove_column :meters, :build_year
    rename_column :meters, :build_year_ng, :build_year
    remove_column :registers, :forecast_kwh_pa

    remove_column :meters, :remote_readout

    add_column :meters, :sent_data_dso, :date
    
    Meter::Base.reset_column_information
    Meter::Base.all.each do |meter|
      meter.update!(sent_data_dso: DataTime.new) if meter.send_data_dso
    end
    remove_column :meters, :send_data_dso
    remove_column :meters, :data_provider_name
    rename_column :meters, :calibrated_till, :calibrated_until

    Register::Base.reset_column_information
    Broker::Base.reset_column_information

    Meter::Base.all.each do |meter|
      equipment = ActiveRecord::Base.connection.execute("select converter_constant from equipment where meter_id = '#{meter.id}' order by created_at").first
      meter.update!(converter_constant: equipment['converter_constant']) if equipment
    end

    drop_table :equipment
  end
end
