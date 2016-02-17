class ChangeOauthApplicationsIdToUuid < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :oauth_applications do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE oauth_applications ADD PRIMARY KEY (id);"
  end
end



