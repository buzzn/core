class CreateBrokers < ActiveRecord::Migration

  def change
    create_table :brokers do |t|
      t.string :type, null: false, length: 32
      t.string :external_id, null: true, length: 64
    end
  end
end
