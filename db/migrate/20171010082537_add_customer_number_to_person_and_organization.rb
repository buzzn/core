class AddCustomerNumberToPersonAndOrganization < ActiveRecord::Migration
  def change
    add_column :persons, :customer_number, :integer, null: true
    add_column :organizations, :customer_number, :integer, null: true
    add_foreign_key :persons, :customer_numbers, name: :fk_persons_customer_number, column: :customer_number
    add_foreign_key :organizations, :customer_numbers, name: :fk_organizations_customer_number, column: :customer_number
  end
end
