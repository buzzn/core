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
          MeteringPoint.guarded_retrieve(current_user, permitted_params)
        end



        desc "Create a MeteringPoint."
        params do
          requires :name, type: String, desc: "name"
          requires :mode, type: String, desc: "direction of energie", values: MeteringPoint.modes
          requires :readable, type: String, desc: "readable by?", values: MeteringPoint.readables
          requires :meter_id, type: String, desc: "Meter ID"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        oauth2 :simple, :full, :smartmeter
        post do
          # TODO move logic into MeteringPoint and validate existence of manager
          meter              = Meter.unguarded_retrieve(permitted_params[:meter_id])
          attributes         = permitted_params.reject { |k,v| k == :meter_id }
          attributes[:meter] = meter
          metering_point     = MeteringPoint.guarded_create(current_user,
                                                            attributes)
          current_user.add_role(:manager, metering_point)
          created_response(metering_point)
        end



        desc "Update a MeteringPoint."
        params do
          requires :id, type: String, desc: 'MeteringPoint ID.'
          optional :name, type: String, desc: "name"
          optional :mode, type: String, desc: "direction of energie", values: MeteringPoint.modes
          optional :readable, type: String, desc: "readable by?", values: MeteringPoint.readables
          optional :meter_id, type: String, desc: "Meter ID"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        oauth2 :simple, :full
        patch ':id' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          # TODO move logic into MeteringPoint
          attributes = permitted_params.reject { |k,v| k == :meter_id }
          if permitted_params[:meter_id]
            meter = Meter.unguarded_retrieve(permitted_params[:meter_id])
            attributes[:meter] = meter
          end
          metering_point.guarded_update(current_user, attributes)
        end



        desc 'Delete a MeteringPoint.'
        params do
          requires :id, type: String, desc: 'MeteringPoint ID.'
        end
        oauth2 :full
        delete ':id' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          deleted_response(metering_point.guarded_delete(current_user))
        end



        desc "Return the related scores for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the metering-point"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/scores" do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(metering_point.scores.readable_by(current_user))
        end



        desc 'Return the related comments for MeteringPoint'
        params do
          requires :id, type: String, desc: 'ID of the MeteringPoint'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ':id/comments' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(metering_point.comment_threads.readable_by(current_user))
        end


        desc "Return the related managers for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get [':id/managers', ':id/relationships/managers'] do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(metering_point.managers.readable_by(current_user))
        end


        desc 'Add user to metering point managers'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/managers' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          if metering_point.updatable_by?(current_user)
            user.add_role(:manager, metering_point)
            user.create_activity(key: 'user.appointed_metering_point_manager', owner: current_user, recipient: metering_point)
            status 204
          else
            status 403
          end
        end



        desc 'Replace metering point managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/managers' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          if metering_point.updatable_by?(current_user)
            # TODO ensure at least ONE manager
            metering_point.replace_managers(id_array, owner: current_user,
                                            create_key: 'user.appointed_metering_point_manager')
          else
            status 403
          end
        end



        desc 'Remove user from metering point managers'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/managers' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          if metering_point.updatable_by?(current_user)
            # TODO move logic into MeteringPoint and ensure at least ONE manager
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
        oauth2 :simple, :full
        get ":id/address" do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          metering_point.address.guarded_read(current_user)
        end


        desc 'Return members of the MeteringPoint'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get [':id/members', ':id/relationships/members'] do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(metering_point.members.readable_by(current_user))
        end


        desc 'Add user to metering point members'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/members' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          if metering_point.updatable_by?(current_user, :members)
            # TODO move logic into MeteringPoint
            user.add_role(:member, metering_point)
            metering_point.create_activity key: 'metering_point_user_membership.create', owner: user
            status 204
          else
            status 403
          end
        end


        desc 'Replace metering point members'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/members' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          if metering_point.updatable_by?(current_user)
            metering_point.replace_members(id_array,
                                           create_key: 'metering_point_user_membership.create',
                                           cancel_key: 'metering_point_user_membership.cancel')
          else
            status 403
          end
        end


        desc 'Remove user from metering point members'
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/members' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          # TODO move logic into ManagerMembers module
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
        oauth2 :simple, :full
        get ':id/meter' do
          metering_point = MeteringPoint.guarded_retrieve(current_user,
                                                          permitted_params)
          metering_point.meter.guarded_read(current_user)
        end


      end
    end
  end
end
