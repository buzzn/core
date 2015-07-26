class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :description, :big_tumb


  def big_tumb
    object.image.big_tumb.url
  end


  has_many :metering_points
end
