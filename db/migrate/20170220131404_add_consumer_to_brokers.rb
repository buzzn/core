class AddConsumerToBrokers < ActiveRecord::Migration
  def change
    add_column :brokers, :consumer_key, :string, null: true
    add_column :brokers, :consumer_secret, :string, null: true
    reversible do |dir|
      dir.up do
        Broker::Discovergy.all.update_all(encrypted_provider_token_key: nil, encrypted_provider_token_secret: nil)
      end
      dir.down do
        Broker::Discovergy.all.update_all(encrypted_provider_token_key: nil, encrypted_provider_token_secret: nil)
      end
    end
  end
end
