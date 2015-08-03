class ProfileSerializer < ActiveModel::Serializer
  attributes  :id,
              :slug,
              :user_name,
              :first_name,
              :last_name,
              :md_img,
              :group_ids,
              :metering_point_ids


  def metering_point_ids
    object.metering_points.collect(&:id)
  end

  def group_ids
    object.metering_points.collect(&:group).compact.uniq.collect(&:id)
  end

  def md_img
    object.image.md.url
  end

end
