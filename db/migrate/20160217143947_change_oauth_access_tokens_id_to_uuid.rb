class ChangeOauthAccessTokensIdToUuid < ActiveRecord::Migration
  def change
    add_column :oauth_access_tokens, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :oauth_access_tokens do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE oauth_access_tokens ADD PRIMARY KEY (id);"
  end
end
