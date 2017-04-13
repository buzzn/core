class CreateBillingCycle < ActiveRecord::Migration
  def change
    create_table :billing_cycles, id: :uuid  do |t|
      t.timestamp :begin_date, null: false
      t.timestamp :end_date, null: false
      t.string :name, null: false

      t.belongs_to :localpool, type: :uuid

      t.timestamps
    end
    add_index :billing_cycles, [:begin_date, :end_date], name: 'index_billing_cycles_dates'

    create_table :billings, id: :uuid  do |t|
      t.string :status, null: false
      t.integer :total_energy_consumption_kWh, null: false
      t.integer :total_price_cents, null: false
      t.integer :prepayments_cents, null: false
      t.integer :receivables_cents, null: false
      t.string :invoice_number, null: true

      t.references :start_reading, references: :readings, type: :string, null: false
      t.references :end_reading, references: :readings, type: :string, null: false
      t.references :device_change_reading_1, references: :readings, type: :string, null: true
      t.references :device_change_reading_2, references: :readings, type: :string, null: true

      t.belongs_to :billing_cycle, type: :uuid
      t.belongs_to :localpool_power_taker_contract, type: :uuid

      t.timestamps
    end
    add_index :billings, :billing_cycle_id
    add_index :billings, :localpool_power_taker_contract_id
    add_index :billings, :status
    add_index :billings, [:billing_cycle_id, :status]
  end
end
