class AddMieterstromzuschlagToGroup < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def change
      add_column :groups, :mieterstromzuschlag, :boolean, :default => false
      Group.reset_column_information
      Group.all.each do |group|
          group = { 
            44 => { "mieterstromzuschlag" => true }, 
            45 => { "mieterstromzuschlag" => true },
            47 => { "mieterstromzuschlag" => true },
            48 => { "mieterstromzuschlag" => true },
            50 => { "mieterstromzuschlag" => true },
            69 => { "mieterstromzuschlag" => true }
          }
      Group.update(group.keys, group.values)
      end
  end

  def down
    remove_column :groups, :mieterstromzuschlag
  end

end