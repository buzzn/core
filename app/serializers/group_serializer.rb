class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :big_tumb, :metering_point_ids


  def big_tumb
    object.image.big_tumb.url
  end

end
