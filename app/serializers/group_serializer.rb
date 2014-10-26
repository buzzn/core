class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :description

  has_many :metering_points
end
