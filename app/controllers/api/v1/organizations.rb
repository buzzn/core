module API
  module V1
    class Organizations < Grape::API
      include API::V1::Defaults
      
      resource :organizations do

        desc "Return all organizations"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Organization.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get do
          per_page         = permitted_params[:per_page]
          page             = permitted_params[:page]
          ids = Organization.filter(permitted_params[:filter]).select do |obj|
            obj.readable_by?(current_user)
          end.collect { |obj| obj.id }
          organizations = Organization.where(id: ids)
          total_pages  = organizations.page(page).per_page(per_page).total_pages
          paginate(render(organizations, meta: { total_pages: total_pages }))
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
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/contracts' do
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            total_pages  = organization.contracts.page(page).per_page(per_page).total_pages
            paginate(render(organization.contracts, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Return the related managers of an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/managers' do
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            total_pages  = organization.managers.page(page).per_page(per_page).total_pages
            paginate(render(organization.managers, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Return the related members of an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/members' do
          organization = Organization.find(permitted_params[:id])
          if organization.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            total_pages  = organization.members.page(page).per_page(per_page).total_pages
            paginate(render(organization.members, meta: { total_pages: total_pages }))
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
          requires :fax,          type: String, desc: "Fax number of Organization."
          optional :website,      type: String, desc: "Website of Organization."
          requires :email,        type: String, desc: "Email of Organization."
          requires :description,  type: String, desc: "Description of the Organization."
          requires :mode,         type: String, desc: 'Mode of Organization', values: Organization.modes
        end
        oauth2 :full
        post do
          if Organization.creatable_by?(current_user)
            organization = Organization.new(permitted_params)
            if organization.save!
              current_user.add_role(:manager, organization)
              return organization
            else
              error!('error saving organization', 500)
            end
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
            organization.update(permitted_params)
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
          requires :user_id, type: String, desc: 'User id'
        end
        oauth2 :full
        post ':id/managers' do
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:user_id])
            user.add_role(:manager, organization)
          else
            status 403
          end
        end


        desc 'Remove user from organization managers'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :user_id, type: String, desc: 'User id'
        end
        oauth2 :full
        delete ':id/managers/:user_id' do
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:user_id])
            user.remove_role(:manager, organization)
            status 204
          else
            status 403
          end
        end


        desc 'Add user to organization members'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :user_id, type: String, desc: 'User id'
        end
        oauth2 :full
        post ':id/members' do
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:user_id])
            user.add_role(:member, organization)
          else
            status 403
          end
        end


        desc 'Remove user from organization members'
        params do
          requires :id, type: String, desc: "Organization ID"
          requires :user_id, type: String, desc: 'User id'
        end
        oauth2 :full
        delete ':id/members/:user_id' do
          organization = Organization.find(permitted_params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(permitted_params[:user_id])
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
