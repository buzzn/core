module API
  module V1
    class Registers < Grape::API
      include API::V1::Defaults
      resource "registers" do


        ["input", "output"].each do |mode|
          klass = "Register::#{mode.camelize}".constantize
          namespace "#{mode}s" do

            desc "Create a #{mode} Register."
            params do
              requires :name, type: String, desc: "name"
              requires :readable, type: String, desc: "readable by?", values: klass.readables
              requires :meter_id, type: String, desc: "Meter ID"
              optional :uid, type: String, desc: "UID(DE00...)"
            end
            oauth2 :simple, :full, :smartmeter
            post do
              meter = Meter.unguarded_retrieve(permitted_params[:meter_id])
              attributes = permitted_params.reject { |k,v| k == :meter_id }
              attributes[:meter] = meter
              register = klass.guarded_create(current_user, attributes)
              created_response(register)
            end


            desc "Update a #{mode} Register."
            params do
              requires :id, type: String, desc: "#{mode} Register ID."
              optional :name, type: String, desc: "name"
              optional :readable, type: String, desc: "readable by?", values: klass.readables
              optional :meter_id, type: String, desc: "Meter ID"
              optional :uid,  type: String, desc: "UID(DE00...)"
            end
            oauth2 :simple, :full
            patch ":id" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              attributes = permitted_params.reject { |k,v| k == :meter_id }
              if permitted_params[:meter_id]
                meter = Meter.unguarded_retrieve(permitted_params[:meter_id])
                attributes[:meter] = meter
              end
              register.guarded_update(current_user, attributes)
            end

          end
        end


        desc "Return a Register"
        params do
          requires :id, type: String, desc: "ID of the register"
        end
        oauth2 false
        get ":id" do
          Register::Base.guarded_retrieve(current_user, permitted_params)
        end



        desc "Delete a Register."
        params do
          requires :id, type: String, desc: "ID of the register"
        end
        oauth2 :full
        delete ":id" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          deleted_response(register.guarded_delete(current_user))
        end



        desc "Return the related scores for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/scores" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(register.scores.readable_by(current_user))
        end



        desc "Return the related comments for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ":id/comments" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(
            Comment.where(
              commentable_type: "Register::Base",
              commentable_id: register.id
              ).readable_by(current_user)
          )
        end


        desc "Return the related managers for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get [":id/managers", ":id/relationships/managers"] do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(register.managers.readable_by(current_user))
        end


        desc "Add user to register managers"
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ":id/relationships/managers" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          user     = User.unguarded_retrieve(data_id)
          register.managers.add(
            current_user,
            user,
            create_key: "user.appointed_register_manager",
            owner: current_user
          )
          status 204
        end



        desc "Replace register managers"
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ":id/relationships/managers" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          # TODO move "key" logic into metering_point/ManagedRoles
          register.managers.replace(current_user,
                                    data_id_array,
                                    owner: current_user,
                                    create_key: "user.appointed_register_manager")
        end



        desc "Remove user from register managers"
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ":id/relationships/managers" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          user     = User.unguarded_retrieve(data_id)
          register.managers.remove(current_user, user)
          status 204
        end


        desc "Return address for the Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get ":id/address" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          register.address.guarded_read(current_user)
        end


        desc "Return members of the Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get [":id/members", ":id/relationships/members"] do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(register.members.readable_by(current_user))
        end


        desc "Add user to register members"
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ":id/relationships/members" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          user     = User.unguarded_retrieve(data_id)
          # TODO move "key" logic into metering_point/ManagedRoles
          register.members.add(current_user,
                               user,
                               update: :members,
                               create_key: "register_user_membership.create")
          status 204
        end


        desc "Replace register members"
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ":id/relationships/members" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          # TODO move "key" logic into metering_point/ManagedRoles
          register.members.replace(current_user,
                                   data_id_array,
                                   update: :members,
                                   create_key: "register_user_membership.create",
                                   cancel_key: "register_user_membership.cancel")
        end


        desc "Remove user from register members"
        params do
          requires :id, type: String, desc: "ID of the Register"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ":id/relationships/members" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          user     = User.unguarded_retrieve(data_id)
          # TODO move "key" logic into metering_point/ManagedRoles
          register.members.remove(current_user,
                                  user,
                                  cancel_key: "register_user_membership.cancel")
        end


        desc "Return meter for the Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get ":id/meter" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          register.meter.guarded_read(current_user)
        end



      end
    end
  end
end
