class MoveMeteringPointsRolesToRegisters < ActiveRecord::Migration
  def up
    Role.where(resource_type: 'MeteringPoint').each do |role|
      role.update_attribute(:resource_type, 'Register')
    end
  end
 
  def down
    Role.where(resource_type: 'Register').each do |role|
      role.update_attribute(:resource_type, 'MeteringPoint')
    end
  end
end
