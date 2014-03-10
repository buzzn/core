class Measurement
  include Mongoid::Document

  field :meter_id,  type: Integer
  field :timestamp, type: DateTime
  field :wh,        type: Integer

  index({ meter_id: 1 })
  index({ timestamp: 1 })
end