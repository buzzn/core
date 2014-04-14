class CreateDistributionSystemOperators < ActiveRecord::Migration
  def change
    create_table :distribution_system_operators do |t|

      t.string :name
      t.string :bdew_code
      t.string :edifact_email
      t.string :contact_name
      t.string :contact_email

      t.integer :metering_point_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
