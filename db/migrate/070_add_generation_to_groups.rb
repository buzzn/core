class AddGenerationToGroups < ActiveRecord::Migration

    def up
      add_column :groups, :generation, :int
    end
  
    def down
      remove_column :groups, :generation
    end
  
  end
  