class GroupResource < ApplicationResource

  attributes  :name,
              :description,
              :big_tumb,
              :md_img,
              :description,
              :readable


  has_many :metering_points
  has_many :devices
  has_many :managers
  has_many :energy_producers
  has_many :energy_consumers
end
