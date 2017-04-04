module Meter
  class Equipment < ActiveRecord::Base
    belongs_to :meter, class_name: Meter::Base
  end
end