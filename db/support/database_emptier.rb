class DatabaseEmptier
  def self.call
    Rails.application.eager_load! # required so all active record classes are loaded and can be iterated over
    ActiveRecord::Base.connection.disable_referential_integrity do
      ActiveRecord::Base.descendants.each do |model|
        begin
          model.delete_all if delete?(model)
        rescue => e
          puts "Failed to delete all #{model} records: #{e.message}"
        end
      end
    end
  end

  def self.delete?(model)
    # abstract classes don't have a table, delete would fail
    return false if model.abstract_class?
    # don't delete the beekeeper data we want to import
    return false if model.respond_to?(:namespace_name) && (model.namespace_name == "Beekeeper")
    true
  end
end
