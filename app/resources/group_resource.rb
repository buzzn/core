class GroupResource < ApplicationResource

  attributes  :name,
              :description,
              :big_tumb,
              :readable, :updateable, :deletable


  has_many :metering_points
end
