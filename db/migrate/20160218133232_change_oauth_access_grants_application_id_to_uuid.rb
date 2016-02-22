class ChangeOauthAccessGrantsApplicationIdToUuid < ActiveRecord::Migration
  def change
    add_column :oauth_access_grants, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :oauth_access_grants do |t|
      t.remove :application_id
      t.rename :uuid, :application_id
    end
  end
end
