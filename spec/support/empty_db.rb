RSpec.configure do |config|
  config.before(:suite) do
    Rails.application.eager_load!
    ActiveRecord::Base.connection.disable_referential_integrity do
      ActiveRecord::Base.descendants.each { |model| model.delete_all unless model.abstract_class? }
    end
  end
end