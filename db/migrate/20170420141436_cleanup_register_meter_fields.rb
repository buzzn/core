class CleanupRegisterMeterFields < ActiveRecord::Migration
  def change
    remove_column :registers, :regular_reeding, :string
    remove_column :registers, :virtual, :string

    remove_column :meters, :init_reading, :boolean
    remove_column :meters, :ancestry, :string
    remove_column :meters, :direction, :string
    remove_column :meters, :rate, :string

    rename_column :meters, :owner, :ownership

    add_column :equipment, :manufacturer_number, :string

    remove_column :profiles, :facebook, :string
    remove_column :profiles, :twitter, :string
    remove_column :profiles, :xing, :string
    remove_column :profiles, :linkedin, :string
    remove_column :profiles, :know_buzzn_from, :string
    remove_column :profiles, :newsletter_notifications, :string
    remove_column :profiles, :location_notifications, :string
    remove_column :profiles, :group_notifications, :string

    remove_column :groups, :closeness, :float
  end
end
