class AddReadableOptionsToLocalpool < ActiveRecord::Migration
  def change
    add_column :groups, :show_object, :boolean
    add_column :groups, :show_production, :boolean
    add_column :groups, :show_energy, :boolean
    add_column :groups, :show_contact, :boolean

    Group::Base.all.each do |g|
      case g.readable
      when 'world'
        g.show_object = true
        g.show_production = true
        g.show_energy = true
        g.show_contact = true
      else
        g.show_object = false
        g.show_production = false
        g.show_energy = false
        g.show_contact = false
      end
    end

    remove_column :groups, :readable
    Group::Base.reset_column_information
  end
end
