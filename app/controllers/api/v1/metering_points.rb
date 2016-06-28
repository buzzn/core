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
          metering_point = MeteringPoint.where(id: params[:id]).first!
          if metering_point.readable_by_world?
            metering_point
          else
            doorkeeper_authorize! :public
            if metering_point.readable_by?(current_user)
              metering_point
            else
              status 403
            end
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


        desc 'Return all related members'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ':id/roles' do
          doorkeeper_authorize! :admin
          metering_point   = MeteringPoint.find(params[:id])
          users            = metering_point.roles.map { |role| User.with_role(role.name, metering_point) }
          users.flatten.uniq
        end



        desc 'Return the related comments for MeteringPoint'
        params do
          requires :id, type: String, desc: 'ID of the MeteringPoint'
        end
        paginate(per_page: per_page=10)
        get ':id/comments' do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: permitted_params[:id]).first!
          if metering_point.readable_by?(current_user)
            @per_page     = params[:per_page] || per_page
            @page         = params[:page] || 1
            @total_pages  = metering_point.comment_threads.page(@page).per_page(@per_page).total_pages
            paginate(render(metering_point.comment_threads, meta: { total_pages: @total_pages }))
          else
            status 403
          end
        end


        desc "Return the related managers for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        paginate(per_page: per_page=10)
        get ":id/managers" do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: permitted_params[:id]).first!
          if metering_point.readable_by?(current_user)
            @per_page     = params[:per_page] || per_page
            @page         = params[:page] || 1
            @total_pages  = metering_point.managers.page(@page).per_page(@per_page).total_pages
            paginate(render(metering_point.managers, meta: { total_pages: @total_pages }))
          else
            status 403
          end
        end


        desc "Return address for the MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ":id/address" do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: permitted_params[:id]).first!
          if metering_point.readable_by?(current_user)
            metering_point.address
          else
            status 403
          end
        end


        desc 'Return members of the MeteringPoint'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ':id/members' do
          metering_point  = MeteringPoint.where(id: permitted_params[:id]).first!
          metering_point.members.select do |member|
            member.profile.readable_by_world? || (current_user && member.profile.readable_by?(current_user))
          end
        end


        desc 'Return meter for the MeteringPoint'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ':id/meter' do
          doorkeeper_authorize! :public
          metering_point = MeteringPoint.where(id: permitted_params[:id]).first!
          if current_user.has_role?(:manager, metering_point)
            metering_point.meter
          else
            status 403
          end
        end


      end
    end
  end
end
