module API
  module V1
    class Organizations < Grape::API
      include API::V1::Defaults
      
      resource :organizations do

        desc "Return all organizations"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Organization.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get do
          paginated_response(Organization.filter(permitted_params[:filter]).readable_by(current_user))
        end



        desc "Return an Organization"
        params do
          requires :id, type: String, desc: "ID of the organization"
        end
        oauth2 false
        get ":id" do
          Organization.guarded_retrieve(current_user, permitted_params)
        end


        desc 'Return the related contracts for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/contracts' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          paginated_response(organization.contracts.readable_by(current_user))
        end


        desc 'Return the related managers of an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get [':id/managers', ':id/relationships/managers'] do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          paginated_response(organization.managers.readable_by(current_user))
        end


        desc 'Return the related members of an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get [':id/members', ':id/relationships/members'] do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          paginated_response(organization.members.readable_by(current_user))
        end


        desc 'Return the related address for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        oauth2 false
        get ':id/address' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          organization.address.guarded_read(current_user)
        end


        desc 'Return the related contracting-party for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        oauth2 false
        get ':id/contracting-party' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          if organization.contracting_party
            organization.contracting_party.guarded_read(current_user)
          end
        end


        desc "Create an Organization."
        params do
          requires :name,         type: String, desc: "Name of the Organization."
          requires :phone,        type: String, desc: "Phone number of Organization."
          requires :email,        type: String, desc: "Email of Organization."
          requires :mode,         type: String, desc: 'Mode of Organization', values: Organization.modes
          optional :fax,          type: String, desc: "Fax number of Organization."
          optional :website,      type: String, desc: "Website of Organization."
          optional :description,  type: String, desc: "Description of the Organization."
        end
        oauth2 :full
        post do
          # TODO move logic into MeteringPoint and ensure at least ONE manager
          organization = Organization.guarded_create(current_user,
                                                     permitted_params)
          current_user.add_role(:manager, organization)
          created_response(organization)
        end



        desc "Update an Organization."
        params do
          requires :id, type: String, desc: "Organization ID."
          optional :name,         type: String, desc: "Name of the Organization."
          optional :phone,        type: String, desc: "Phone number of Organization."
          optional :fax,          type: String, desc: "Fax number of Organization."
          optional :website,      type: String, desc: "Website of Organization."
          optional :email,        type: String, desc: "Email of Organization."
          optional :description,  type: String, desc: "Description of the Organization."
          optional :mode,         type: String, desc: 'Mode of Organization', values: Organization.modes
        end
        oauth2 :full
        patch ':id' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          organization.guarded_update(current_user, permitted_params)
        end



        desc 'Delete an Organization.'
        params do
          requires :id, type: String, desc: "Organization ID"
        end
        oauth2 :full
        delete ':id' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          if organization.deletable_by?(current_user)
            organization.destroy
            status 204
          else
            status 403
          end
        end


        desc 'Add user to organization managers'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/managers' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          user         = User.unguarded_retrieve(permitted_params[:data][:id])
          if organization.updatable_by?(current_user)
            user.add_role(:manager, organization)
            status 204
          else
            status 403
          end
        end


        desc 'Replace organization managers'
        params do
          requires :id, type: String, desc: "ID of the organization"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/managers' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          if organization.updatable_by?(current_user)
            organization.replace_managers(id_array)
          else
            status 403
          end
        end


        desc 'Remove user from organization managers'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/managers' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          user         = User.unguarded_retrieve(permitted_params[:data][:id])
          if organization.updatable_by?(current_user)
            user.remove_role(:manager, organization)
            status 204
          else
            status 403
          end
        end


        desc 'Add user to organization members'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/members' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          user         = User.unguarded_retrieve(permitted_params[:data][:id])
          if organization.updatable_by?(current_user)
            user.add_role(:member, organization)
            status 204
          else
            status 403
          end
        end


        desc 'Replace organization members'
        params do
          requires :id, type: String, desc: "ID of the organization"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/members' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          if organization.updatable_by?(current_user)
            organization.replace_members(id_array)
          else
            status 403
          end
        end


        desc 'Remove user from organization members'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :data, type: Hash do
            optional :type, type: String, values: [Organization.to_s], default: Organization.to_s
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/members' do
          organization = Organization.guarded_retrieve(current_user,
                                                       permitted_params)
          user         = User.unguarded_retrieve(permitted_params[:data][:id])
          if organization.updatable_by?(current_user)
            user.remove_role(:member, organization)
            status 204
          else
            status 403
          end
        end
      end
    end
  end
end
