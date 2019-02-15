class AddFakeStatsToGroup < ActiveRecord::Migration

  def change
    add_column :groups, :fake_stats, :json
  end

end
