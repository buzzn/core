class GroupResource < ApplicationResource

  attributes  :name,
              :description,
              :big_tumb,
              :md_img,
              :description,
              :readable, :updateable, :deletable


  has_many :metering_points
end
