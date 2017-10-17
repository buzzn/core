class CreateCustomerNumber < ActiveRecord::Migration
  def change
    create_table :customer_numbers
    execute('ALTER SEQUENCE customer_numbers_id_seq START with 100000 RESTART')
  end
end
