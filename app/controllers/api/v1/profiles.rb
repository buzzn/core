module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource :profiles do



        desc "Return me"
        get "me" do
          guard!
          current_user.profile
        end



        desc "Return all profiles"
        get "" do
          Profile.all
        end



        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id" do
          Profile.where(id: permitted_params[:id]).first!
        end



        desc "Return the related groups for Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/groups" do
          profile = Profile.where(id: permitted_params[:id]).first!
          render profile.metering_points.collect(&:group).compact.uniq
        end



  # def metering_point_ids
  #   @model.metering_points.collect(&:id)
  # end

  # def group_ids
  #   @model.metering_points.collect(&:group).compact.uniq.collect(&:id)
  # end

  # def friendship_ids
  #   @model.user.friendship_ids
  # end





      end
    end
  end
end
