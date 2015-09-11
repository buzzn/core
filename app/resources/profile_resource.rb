class ProfileResource < ApplicationResource

  attributes  :id,
              :slug,
              :user_name,
              :first_name,
              :last_name,
              :md_img,
              :group_ids,
              :metering_point_ids,
              :friendship_ids


  def metering_point_ids
    @model.metering_points.collect(&:id)
  end

  def group_ids
    @model.metering_points.collect(&:group).compact.uniq.collect(&:id)
  end

  def friendship_ids
    @model.user.friendship_ids
  end

end
