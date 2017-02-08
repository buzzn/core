class MoveModeToTypeOnGroups < ActiveRecord::Migration
  def change
      Group::Base.all.each do |group|
        if group.mode == 'localpool'
          group.type = Group::Localpool
        else
          group.type = Group::Tribe
        end
        group.save
      end
  end
end
