class ChangeVotableToUuid < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'
    remove_column :votes, :votable_id
    add_column :votes, :votable_id, :uuid
    remove_column :votes, :voter_id
    add_column :votes, :voter_id, :uuid
  end

  def down
    remove_column :comments, :votable_id
    add_column :comments, :votable_id
    remove_column :votes, :voter_id
    add_column :votes, :voter_id
  end
end
