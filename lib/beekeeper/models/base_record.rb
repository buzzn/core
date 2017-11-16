class Beekeeper::BaseRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection ENV['BEEKEEPER_DATABASE_URL']
end
