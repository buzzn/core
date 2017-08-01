class EnumsForAddresses < ActiveRecord::Migration
  def up
    create_enum :country, *Address::COUNTRIES
    create_enum :state, *Address::STATES

    remove_column :addresses, :time_zone
    remove_column :addresses, :address
    remove_column :addresses, :country
    remove_column :addresses, :state
    add_column :addresses, :street, :string, null: true
    add_column :addresses, :state, :state, null: true
    add_column :addresses, :country, :country, null: false, default: 'DE'

    Address.all.each do |a|
      a.update(street: a.street_name + ' ' + a.street_number)
    end

    change_column :addresses, :street, :string, null: false, limit: 64
    change_column :addresses, :zip, :string, null: false, limit: 16

    remove_column  :addresses, :street_name
    remove_column  :addresses, :street_number

    Address.reset_column_information
  end
end
