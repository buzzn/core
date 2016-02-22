class ChangeOauthAccessTokensApplicationIdToUuid < ActiveRecord::Migration
  def change
    add_column :oauth_access_tokens, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :oauth_access_tokens do |t|
      t.remove :application_id
      t.rename :uuid, :application_id
    end
  end
end
