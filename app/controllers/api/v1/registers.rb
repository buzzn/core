module API
  module V1
    class Registers < Grape::API
      include API::V1::Defaults
      resource 'registers' do


        desc "Return a Register"
        params do
          requires :id, type: String, desc: "ID of the register"
        end
        oauth2 false
        get ":id" do
          Register.guarded_retrieve(current_user, permitted_params)
        end



        desc "Create a Register."
        params do
          requires :name, type: String, desc: "name"
          requires :mode, type: String, desc: "direction of energie", values: Register.modes
          requires :readable, type: String, desc: "readable by?", values: Register.readables
          requires :meter_id, type: String, desc: "Meter ID"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        oauth2 :simple, :full, :smartmeter
        post do
          # TODO move logic into Register and validate existence of manager
          meter              = Meter.unguarded_retrieve(permitted_params[:meter_id])
          attributes         = permitted_params.reject { |k,v| k == :meter_id }
          attributes[:meter] = meter
          register     = Register.guarded_create(current_user,
                                                            attributes)
          current_user.add_role(:manager, register)
          created_response(register)
        end



        desc "Update a Register."
        params do
          requires :id, type: String, desc: 'Register ID.'
          optional :name, type: String, desc: "name"
          optional :mode, type: String, desc: "direction of energie", values: Register.modes
          optional :readable, type: String, desc: "readable by?", values: Register.readables
          optional :meter_id, type: String, desc: "Meter ID"
          optional :uid,  type: String, desc: "UID(DE00...)"
        end
        oauth2 :simple, :full
        patch ':id' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          attributes = permitted_params.reject { |k,v| k == :meter_id }
          if permitted_params[:meter_id]
            meter = Meter.unguarded_retrieve(permitted_params[:meter_id])
            attributes[:meter] = meter
          end
          register.guarded_update(current_user, attributes)
        end



        desc 'Delete a Register.'
        params do
          requires :id, type: String, desc: 'Register ID.'
        end
        oauth2 :full
        delete ':id' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          deleted_response(register.guarded_delete(current_user))
        end



        desc "Return the related scores for Register"
        params do
          requires :id, type: String, desc: "ID of the register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/scores" do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(register.scores.readable_by(current_user))
        end



        desc 'Return the related comments for Register'
        params do
          requires :id, type: String, desc: 'ID of the Register'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ':id/comments' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(register.comment_threads.readable_by(current_user))
        end


        desc "Return the related managers for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get [':id/managers', ':id/relationships/managers'] do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(register.managers.readable_by(current_user))
        end


        desc 'Add user to register managers'
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/managers' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          if register.updatable_by?(current_user)
            metering_point.managers.add(user, create_key: 'user.appointed_metering_point_manager', owner: current_user)
            status 204
          else
            status 403
          end
        end



        desc 'Replace register managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/managers' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          if register.updatable_by?(current_user)
            register.managers.replace(id_array, owner: current_user,
                                      create_key: 'user.appointed_register_manager')
          else
            status 403
          end
        end



        desc 'Remove user from register managers'
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/managers' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          if register.updatable_by?(current_user)
            # TODO move logic into Register and ensure at least ONE manager
            user.remove_role(:manager, register)
            status 204
          else
            status 403
          end
        end


        desc "Return address for the Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get ":id/address" do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          register.address.guarded_read(current_user)
        end


        desc 'Return members of the Register'
        params do
          requires :id, type: String, desc: "ID of the Register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get [':id/members', ':id/relationships/members'] do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          paginated_response(register.members.readable_by(current_user))
        end


        desc 'Add user to register members'
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/members' do
          register = Register.guarded_retrieve(current_user,
                                               permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          if register.updatable_by?(current_user, :members)
            # TODO move logic into MeteringPoint
            register.members.add(user, create_key: 'metering_point_user_membership.create')
            status 204
          else
            status 403
          end
        end


        desc 'Replace register members'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/members' do
          register = Register.guarded_retrieve(current_user,
                                               permitted_params)
          if register.updatable_by?(current_user)
            register.members.replace(id_array,
                                     create_key: 'register_user_membership.create',
                                     cancel_key: 'register_user_membership.cancel')
          else
            status 403
          end
        end


        desc 'Remove user from register members'
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/members' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          user           = User.unguarded_retrieve(permitted_params[:data][:id])
          # TODO move logic into ManagerMembers module
          if (current_user == user ||
              register.updatable_by?(current_user))
            register.members.remove(user, cancel_key: 'register_user_membership.cancel')
          else
            status 403
          end
        end


        desc 'Return meter for the Register'
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get ':id/meter' do
          register = Register.guarded_retrieve(current_user,
                                                          permitted_params)
          register.meter.guarded_read(current_user)
        end


      end
    end
  end
end
