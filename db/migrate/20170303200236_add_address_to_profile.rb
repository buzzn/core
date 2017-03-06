class AddAddressToProfile < ActiveRecord::Migration
  def change
    # 'address' is the english translation for 'Anrede'
    add_column :profiles, :address, :string
  end
end
