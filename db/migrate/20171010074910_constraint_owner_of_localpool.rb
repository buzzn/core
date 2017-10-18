class ConstraintOwnerOfLocalpool < ActiveRecord::Migration  
  def self.up
    execute 'ALTER TABLE groups ADD CONSTRAINT check_localpool_owner CHECK (NOT (person_id IS NOT NULL AND organization_id IS NOT NULL))'
  end

  def self.down
    execute 'ALTER TABLE groupse DROP CONSTRAINT check_localpool_owner'
  end
end
