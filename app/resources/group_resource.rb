class GroupResource < ApplicationResource

  attributes  :id,
              :name,
              :description,
              :big_tumb,
              :readable, :updateable, :deletable,
              :metering_point_ids


end
