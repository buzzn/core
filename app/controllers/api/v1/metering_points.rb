module API
  module V1
    class MeteringPoints < Grape::API
      include API::V1::Defaults
      resource 'metering-points' do


        desc "Return a MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the metering_point"
        end
        get ":id" do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: params[:id]).first!
          if current_user
            if metering_point.readable_by?(current_user)
              return metering_point
            else
              status 403
            end
          else
            status 401
          end
        end



        desc "Create a MeteringPoint."
        params do
          requires :name, type: String, desc: "name"
          requires :mode, type: String, desc: "direction of energie", values: MeteringPoint.modes
          requires :readable, type: String, desc: "readable by?", values: MeteringPoint.readables
          requires :meter_id, type: String, desc: "Meter"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        post do
          doorkeeper_authorize! :public
          if current_user
            if MeteringPoint.creatable_by?(current_user)
              metering_point = MeteringPoint.new({
                name: params[:name],
                mode: params[:mode],
                readable: params[:readable],
                meter_id: params[:meter_id],
                uid: params[:uid]
                })
              if metering_point.save!
                current_user.add_role(:manager, metering_point)
                return metering_point
              end
            else
              status 403
            end
          else
            status 401
          end
        end



        desc "Update a MeteringPoint."
        params do
          requires :id, type: String, desc: 'MeteringPoint ID.'
          requires :name, type: String, desc: "name"
          requires :mode, type: String, desc: "direction of energie", values: MeteringPoint.modes
          requires :readable, type: String, desc: "readable by?", values: MeteringPoint.readables
          requires :meter_id, type: String, desc: "Meter"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        put do
          doorkeeper_authorize! :public
          if current_user
            metering_point = MeteringPoint.find(params[:id])
            if metering_point.updatable_by?(current_user)
              metering_point.update({
                name: params[:name],
                mode: params[:mode],
                readable: params[:readable],
                meter_id: params[:meter_id],
                uid: params[:uid]
              })
              return metering_point
            else
              status 403
            end
          else
            status 401
          end
        end



        desc 'Delete a MeteringPoint.'
        params do
          requires :id, type: String, desc: 'MeteringPoint ID.'
        end
        delete ':id' do
          doorkeeper_authorize! :public
          if current_user
            metering_point = MeteringPoint.find(params[:id])
            if metering_point.deletable_by?(current_user)
              metering_point.destroy
              status 204
            else
              status 403
            end
          else
            status 401
          end
        end



        desc "Return the related devices for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ":id/devices" do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: params[:id]).first!
          metering_point.devices
        end



        desc "Return the related users for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ":id/users" do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: params[:id]).first!
          metering_point.users
        end




      end
    end
  end
end
