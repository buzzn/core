module API
  module V1
    class Registers < Grape::API
      include API::V1::Defaults
      resource :registers do


        namespace :real do
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
                # FIXME remove this in favour of meters/real/:id/input_register
                #       meters/real/:id/output_register
                meter = Meter::Base.unguarded_retrieve(permitted_params[:meter_id])
                attributes = permitted_params.reject { |k,v| k == :meter_id }
                attributes[:meter] = meter
                register = klass.guarded_create(current_user, attributes)
                created_response(Register::RealSerializer.new(register))
              end
            end

          end

          desc "Update a Real-Register."
          params do
            requires :id, type: String, desc: "Register ID."
            optional :name, type: String, desc: "name"
            optional :readable, type: String, desc: "readable by?", values: Register::Base.readables
            optional :uid,  type: String, desc: "UID(DE00...)"
          end
          oauth2 :simple, :full
          patch ":id" do
            Register::RealResource
              .retrieve(current_user, permitted_params)
              .update(permitted_params)
          end

          desc "Delete a Register."
          params do
            requires :id, type: String, desc: "ID of the register"
          end
          oauth2 :full
          delete ":id" do
            deleted_response(Register::RealResource
                              .retrieve(current_user, permitted_params)
                              .delete)
          end
        end




        namespace :virtual do
          desc "Update a Virtual-Register."
          params do
            requires :id, type: String, desc: "Register ID."
            optional :name, type: String, desc: "name"
            optional :readable, type: String, desc: "readable by?", values: Register::Base.readables
          end
          oauth2 :simple, :full
          patch ":id" do
            Register::VirtualResource
              .retrieve(current_user, permitted_params)
              .update(permitted_params)
          end
        end




        desc "Return a Register"
        params do
          requires :id, type: String, desc: "ID of the register"
        end
        oauth2 false
        get ":id" do
          Register::BaseResource.retrieve(current_user, permitted_params)
        end




        desc "Return the related scores for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 false
        get ":id/scores" do
          Register::BaseResource
            .retrieve(current_user, permitted_params)
            .scores
        end



        desc "Return the related comments for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get ":id/comments" do
          Register::BaseResource
            .retrieve(current_user, permitted_params)
            .comments
        end


        desc "Return the related managers for Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get [":id/managers", ":id/relationships/managers"] do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          register.managers.readable_by(current_user)
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
          status 200
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
          Register::BaseResource
            .retrieve(current_user, permitted_params)
            .address!
        end


        desc "Return members of the Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 false
        get [":id/members", ":id/relationships/members"] do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          register.members.readable_by(current_user)
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
          status 200
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
          status 204
        end


        desc "Return meter for the Register"
        params do
          requires :id, type: String, desc: "ID of the Register"
        end
        oauth2 :simple, :full
        get ":id/meter" do
          Register::BaseResource
            .retrieve(current_user, permitted_params)
            .meter!
        end

      end
    end
  end
end
