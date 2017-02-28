class ChangeBrokerStringsInDb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Broker::Base.all.update_all(type: "Broker::Discovergy")
        end
      end

      dir.down do
        ActiveRecord::Base.transaction do
          Broker::Base.all.update_all(type: "DiscovergyBroker")
        end
      end
    end
  end
end
