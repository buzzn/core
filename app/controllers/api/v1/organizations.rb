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
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            organization
          else
            status 403
          end
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
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            paginated_response(organization.contracts.readable_by(current_user))
          else
            status 403
          end
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
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            paginated_response(organization.managers)
          else
            status 403
          end
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
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            paginated_response(organization.members)
          else
            status 403
          end
        end


        desc 'Return the related address for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        oauth2 false
        get ':id/address' do
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            organization.address
          else
            status 403
          end
        end


        desc 'Return the related contracting-party for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        oauth2 false
        get ':id/contracting_party' do
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            organization.contracting_party
          else
            status 403
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
          if Organization.creatable_by?(current_user)
            organization = Organization.create!(permitted_params)
            current_user.add_role(:manager, organization)
            created_response(organization)
          else
            status 403
          end
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
          organization = Organization.find(permitted_params[:id])

          if organization.updatable_by?(current_user)
            organization.update!(permitted_params)
            return organization
          else
            status 403
          end
        end



        desc 'Delete an Organization.'
        params do
          requires :id, type: String, desc: "Organization ID"
        end
        oauth2 :full
        delete ':id' do
          organization = Organization.find(permitted_params[:id])
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
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:data][:id])
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
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            ids = permitted_params[:data].collect{ |d| d[:id] }
            organization.replace_managers(ids)
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
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:data][:id])
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
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:data][:id])
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
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            ids = permitted_params[:data].collect{ |d| d[:id] }
            organization.replace_members(ids)
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
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:data][:id])
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
