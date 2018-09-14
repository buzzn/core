require 'buzzn/schemas/constraints/billing_detail'

class CreateBillingDetail < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::BillingDetail)

  def up
    SCHEMA.up(:billing_details, self)

    add_belongs_to :groups, :billing_detail, index: true, null: true
    add_foreign_key :groups, :billing_details, name: :fk_groups_billing_detail, column: :billing_detail_id

    execute 'ALTER TABLE billing_details ADD CONSTRAINT valid_power_factor_range CHECK (reduced_power_factor >= 0 AND reduced_power_factor <= 1)'
    execute 'ALTER TABLE billing_details ADD CONSTRAINT valid_power_amount CHECK (reduced_power_amount >= 0)'
    execute 'ALTER TABLE billing_details ADD CONSTRAINT valid_automatic_abschlag_threshold CHECK (automatic_abschlag_threshold >= 0)'
  end

  def down
    execute 'ALTER TABLE billing_details DROP CONSTRAINT valid_power_factor_range'
    execute 'ALTER TABLE billing_details DROP CONSTRAINT valid_power_amount'
    execute 'ALTER TABLE billing_details DROP CONSTRAINT valid_automatic_abschlag_threshold'
    SCHEMA.down(:billing_details, self)
  end

end
