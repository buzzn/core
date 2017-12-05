module Broker
  class Base < ActiveRecord::Base
    self.table_name = :brokers

    has_one :meter, class_name: 'Meter::Base', foreign_key: 'broker_id'

    def data_source; raise 'not implemented'; end
  end
end
