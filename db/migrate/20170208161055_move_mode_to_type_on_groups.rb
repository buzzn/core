class MoveModeToTypeOnGroups < ActiveRecord::Migration
  def up
    Group::Base.all.each do |group|
      if group.mode == 'localpool'
        group.type = Group::Localpool
      else
        group.type = Group::Tribe
      end
      group.save!
    end
  end

  def down
    Group::Base.all.each do |group|
      if group.type == 'Group::Localpool'
        group.mode = 'localpool'
      else
        group.mode = ''
      end
      group.save!
    end
  end

end
