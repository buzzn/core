class CreateMeteringServiceProviderContracts < ActiveRecord::Migration
  def change
    create_table :metering_service_provider_contracts do |t|

      t.string :customer_number
      t.string :contract_number

      t.integer :metering_service_provider_id
      t.integer :meter_id

      t.timestamps
    end
  end
end
