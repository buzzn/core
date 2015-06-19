class AddForecastKwhPaToMeteringPoints < ActiveRecord::Migration
  def change
    add_column :metering_points, :forecast_kwh_pa, :integer
  end
end
