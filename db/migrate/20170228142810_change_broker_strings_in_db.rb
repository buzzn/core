class ChangeBrokerStringsInDb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Broker::Base.all.each do |broker|
            broker.type = "Broker::Discovergy"
            broker.save
          end
        end
      end

      dir.down do
        puts "nothing to do here ..."
      end
    end
  end
end
