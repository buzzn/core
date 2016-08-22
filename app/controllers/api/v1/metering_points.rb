module API
  module V1
    class MeteringPoints < Grape::API
      include API::V1::Defaults
      resource 'metering-points' do


        desc "Return a MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the metering_point"
        end
        oauth2 false
        get ":id" do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.readable_by?(current_user)
            metering_point
          else
            status 403
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
        oauth2 :public, :full, :smartmeter
        post do
          if MeteringPoint.creatable_by?(current_user)
            meter = Meter.find(permitted_params[:meter_id])
            attributes = permitted_params.reject { |k,v| k == :meter_id }
            attributes[:meter] = meter
            metering_point = MeteringPoint.create!(attributes)
            current_user.add_role(:manager, metering_point)
            created_response(metering_point)
          else
            status 403
          end
        end



        desc "Update a MeteringPoint."
        params do
          requires :id, type: String, desc: 'MeteringPoint ID.'
          optional :name, type: String, desc: "name"
          optional :mode, type: String, desc: "direction of energie", values: MeteringPoint.modes
          optional :readable, type: String, desc: "readable by?", values: MeteringPoint.readables
          optional :meter_id, type: String, desc: "Meter"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        oauth2 :public, :full
        patch ':id' do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.updatable_by?(current_user)
            attributes = permitted_params.reject { |k,v| k == :meter_id }
            if permitted_params[:meter_id]
              meter = Meter.find(permitted_params[:meter_id])
              attributes[:meter] = meter
            end
            metering_point.update!(attributes)
            metering_point
          else
            status 403
          end
        end



        desc 'Delete a MeteringPoint.'
        params do
          requires :id, type: String, desc: 'MeteringPoint ID.'
        end
        oauth2 :full
        delete ':id' do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.deletable_by?(current_user)
            metering_point.destroy
            status 204
          else
            status 403
          end
        end



        desc 'Return the related comments for MeteringPoint'
        params do
          requires :id, type: String, desc: 'ID of the MeteringPoint'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ':id/comments' do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.readable_by?(current_user)
            paginated_response(metering_point.comment_threads)
          else
            status 403
          end
        end


        desc "Return the related managers for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/managers" do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.readable_by?(current_user)
            paginated_response(metering_point.managers)
          else
            status 403
          end
        end


        desc 'Add user to metering point managers'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :user_id, type: String, desc: 'User ID'
        end
        oauth2 :full
        post ':id/managers' do
          metering_point  = MeteringPoint.find(permitted_params[:id])
          user            = User.find(permitted_params[:user_id])
          if metering_point.updatable_by?(current_user)
            user.add_role(:manager, metering_point)
            user.create_activity(key: 'user.appointed_metering_point_manager', owner: current_user, recipient: metering_point)
            status 204
          else
            status 403
          end
        end


        desc 'Remove user from metering point managers'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :user_id, type: String, desc: 'User ID'
        end
        oauth2 :full
        delete ':id/managers/:user_id' do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.updatable_by?(current_user)
            user = User.find(permitted_params[:user_id])
            user.remove_role(:manager, metering_point)
            status 204
          else
            status 403
          end
        end


        desc "Return address for the MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        oauth2 :public, :full
        get ":id/address" do
          metering_point  = MeteringPoint.find(permitted_params[:id])
          if metering_point.readable_by?(current_user)
            metering_point.address
          else
            status 403
          end
        end


        desc 'Return members of the MeteringPoint'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/members' do
          metering_point = MeteringPoint.find(permitted_params[:id])
          if metering_point.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            
            ids = metering_point.members.select do |member|
              member.profile.readable_by?(current_user)
            end
            members =  metering_point.members.where(id: ids)
            total_pages  = members.page(page).per_page(per_page).total_pages
            paginate(render(members, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Add user to metering point members'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :user_id, type: String, desc: 'User ID'
        end
        oauth2 :full
        post ':id/members' do
          metering_point  = MeteringPoint.find(permitted_params[:id])
          user            = User.find(permitted_params[:user_id])
          if metering_point.updatable_by?(current_user, :members)
            user.add_role(:member, metering_point)
            metering_point.create_activity key: 'metering_point_user_membership.create', owner: user
            status 204
          else
            status 403
          end
        end


        desc 'Remove user from metering point members'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :user_id, type: String, desc: 'User ID'
        end
        oauth2 :full
        delete ':id/members/:user_id' do
          metering_point  = MeteringPoint.find(permitted_params[:id])
          user            = User.find(permitted_params[:user_id])
          if (current_user == user ||
              metering_point.updatable_by?(current_user))
            user.remove_role(:member, metering_point)
            metering_point.create_activity(key: 'metering_point_user_membership.cancel', owner: user)
          else
            status 403
          end
        end


        desc 'Return meter for the MeteringPoint'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        oauth2 :public, :full
        get ':id/meter' do
          metering_point  = MeteringPoint.find(permitted_params[:id])
          if metering_point.readable_by?(current_user, :meter)
            metering_point.meter
          else
            status 403
          end
        end


      end
    end
  end
end
