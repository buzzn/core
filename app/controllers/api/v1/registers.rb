module API
  module V1
    class Registers < Grape::API
      include API::V1::Defaults
      resource "registers" do
        ["input", "output"].each do |mode|
          klass = "Register::#{mode.camelize}".constantize
          namespace "#{mode}s" do


            desc "Return a #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} register"
            end
            oauth2 false
            get ":id" do
              klass.guarded_retrieve(current_user, permitted_params)
            end


            desc "Create a #{mode} Register."
            params do
              requires :name, type: String, desc: "name"
              optional :mode, type: String, desc: "direction of energie", values: klass.modes
              requires :readable, type: String, desc: "readable by?", values: klass.readables
              requires :meter_id, type: String, desc: "Meter ID"
              optional :uid, type: String, desc: "UID(DE00...)"
            end
            oauth2 :simple, :full, :smartmeter
            post do
              attributes = permitted_params.reject { |k,v| k == :meter_id }
              if permitted_params[:meter_id]
                meter = Meter.unguarded_retrieve(permitted_params[:meter_id])
                attributes[:meter] = meter
              end
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


            desc "Delete a #{mode} Register."
            params do
              requires :id, type: String, desc: "#{mode} Register ID."
            end
            oauth2 :full
            delete ":id" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              deleted_response(register.guarded_delete(current_user))
            end






            desc "Return the related scores for #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
              optional :page, type: Fixnum, desc: "Page number", default: 1
            end
            paginate
            oauth2 false
            get ":id/scores" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              paginated_response(register.scores.readable_by(current_user))
            end



            desc "Return the related comments for #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
              optional :page, type: Fixnum, desc: "Page number", default: 1
            end
            paginate
            oauth2 :simple, :full
            get ":id/comments" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              paginated_response(register.comment_threads.readable_by(current_user))
            end


            desc "Return the related managers for #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
              optional :page, type: Fixnum, desc: "Page number", default: 1
            end
            paginate
            oauth2 :simple, :full
            get [":id/managers", ":id/relationships/managers"] do
              register = klass.guarded_retrieve(current_user, permitted_params)
              paginated_response(register.managers.readable_by(current_user))
            end


            desc "Add user to register managers"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              requires :data, type: Hash do
                requires :id, type: String, desc: "ID of the user"
              end
            end
            oauth2 :full
            post ":id/relationships/managers" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              user     = User.unguarded_retrieve(data_id)
              register.managers.add(
                current_user,
                user,
                create_key: "user.appointed_register_manager",
                owner: current_user
              )
              status 204
            end



            desc "Replace #{mode} register managers"
            params do
              requires :id, type: String, desc: "ID of the group"
              requires :data, type: Array do
                requires :id, type: String, desc: "ID of the user"
              end
            end
            oauth2 :full
            patch ":id/relationships/managers" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              # TODO move "key" logic into metering_point/ManagedRoles
              register.managers.replace(current_user,
                                        data_id_array,
                                        owner: current_user,
                                        create_key: "user.appointed_register_manager")
            end



            desc "Remove user from #{mode} register managers"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              requires :data, type: Hash do
                requires :id, type: String, desc: "ID of the user"
              end
            end
            oauth2 :full
            delete ":id/relationships/managers" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              user     = User.unguarded_retrieve(data_id)
              register.managers.remove(current_user, user)
              status 204
            end


            desc "Return address for the #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
            end
            oauth2 :simple, :full
            get ":id/address" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              register.address.guarded_read(current_user)
            end


            desc "Return members of the #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
              optional :page, type: Fixnum, desc: "Page number", default: 1
            end
            paginate
            oauth2 false
            get [":id/members", ":id/relationships/members"] do
              register = klass.guarded_retrieve(current_user, permitted_params)
              paginated_response(register.members.readable_by(current_user))
            end


            desc "Add user to #{mode} register members"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              requires :data, type: Hash do
                requires :id, type: String, desc: "ID of the user"
              end
            end
            oauth2 :full
            post ":id/relationships/members" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              user     = User.unguarded_retrieve(data_id)
              # TODO move "key" logic into metering_point/ManagedRoles
              register.members.add(current_user,
                                   user,
                                   update: :members,
                                   create_key: "register_user_membership.create")
              status 204
            end


            desc "Replace #{mode} register members"
            params do
              requires :id, type: String, desc: "ID of the group"
              requires :data, type: Array do
                requires :id, type: String, desc: "ID of the user"
              end
            end
            oauth2 :full
            patch ":id/relationships/members" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              # TODO move "key" logic into metering_point/ManagedRoles
              register.members.replace(current_user,
                                       data_id_array,
                                       update: :members,
                                       create_key: "register_user_membership.create",
                                       cancel_key: "register_user_membership.cancel")
            end


            desc "Remove user from #{mode} register members"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
              requires :data, type: Hash do
                requires :id, type: String, desc: "ID of the user"
              end
            end
            oauth2 :full
            delete ":id/relationships/members" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              user     = User.unguarded_retrieve(data_id)
              # TODO move "key" logic into metering_point/ManagedRoles
              register.members.remove(current_user,
                                      user,
                                      cancel_key: "register_user_membership.cancel")
            end


            desc "Return meter for the #{mode} Register"
            params do
              requires :id, type: String, desc: "ID of the #{mode} Register"
            end
            oauth2 :simple, :full
            get ":id/meter" do
              register = klass.guarded_retrieve(current_user, permitted_params)
              register.meter.guarded_read(current_user)
            end




          end
        end
      end
    end
  end
end
