module API
  module V1
    class Organizations < Grape::API
      include API::V1::Defaults
      
      resource :organizations do

        desc "Return all organizations"
        paginate(per_page: per_page=10)
        get root: :organizations do
          per_page         = params[:per_page] || per_page
          page             = params[:page] || 1
          organization_ids = Organization.all.select do |org|
            org.readable_by?(current_user)
          end.collect { |org| org.id }
          organizations = Organization.where(id: organization_ids)
          total_pages  = organizations.page(page).per_page(per_page).total_pages
          paginate(render(organizations, meta: { total_pages: total_pages }))
        end



        desc "Return an Organization"
        params do
          requires :id, type: String, desc: "ID of the organization"
        end
        get ":id", root: "organization" do
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            organization
          else
            status 403
          end
        end


        desc 'Return the related contracts for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        paginate(per_page: per_page=10)
        get ':id/contracts' do
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            per_page     = params[:per_page] || per_page
            page         = params[:page] || 1
            total_pages  = organization.contracts.page(page).per_page(per_page).total_pages
            paginate(render(organization.contracts, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Return the related managers of an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        paginate(per_page: per_page=10)
        get ':id/managers' do
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            per_page     = params[:per_page] || per_page
            page         = params[:page] || 1
            total_pages  = organization.managers.page(page).per_page(per_page).total_pages
            paginate(render(organization.managers, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Return the related members of an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        paginate(per_page: per_page=10)
        get ':id/members' do
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            per_page     = params[:per_page] || per_page
            page         = params[:page] || 1
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
        get ':id/address' do
          organization = Organization.where(id: permitted_params[:id]).first!
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
        get ':id/contracting_party' do
          organization = Organization.where(id: permitted_params[:id]).first!
          if organization.readable_by?(current_user)
            organization.contracting_party
          else
            status 403
          end
        end


        before do
          doorkeeper_authorize! :admin
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
        post do
          if Organization.creatable_by?(current_user)
            organization = Organization.new({
                name:        params.name,
                phone:       params.phone,
                fax:         params.fax,
                website:     params.website,
                description: params.description,
                mode:        params.mode,
                email:       params.email
            })

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
          requires :name,         type: String, desc: "Name of the Organization."
          requires :phone,        type: String, desc: "Phone number of Organization."
          requires :fax,          type: String, desc: "Fax number of Organization."
          optional :website,      type: String, desc: "Website of Organization."
          requires :email,        type: String, desc: "Email of Organization."
          requires :description,  type: String, desc: "Description of the Organization."
          requires :mode,         type: String, desc: 'Mode of Organization', values: Organization.modes
        end
        put do
          organization = Organization.find(params[:id])

          if organization.updatable_by?(current_user)
            params.delete(:id)
            organization.update(params)
            return organization
          else
            status 403
          end
        end



        desc 'Delete an Organization.'
        params do
          requires :id, type: String, desc: "Organization ID"
        end
        delete ':id' do
          organization = Organization.find(params[:id])
          if organization.deletable_by?(current_user)
            organization.destroy
            status 204
          else
            status 403
          end
        end


        desc 'Add user to organization managers'
        params do
          requires :user_id, type: String, desc: 'User id'
        end
        post ':id/managers' do
          organization = Organization.find(params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(params[:user_id])
            user.add_role(:manager, organization)
          else
            status 403
          end
        end


        desc 'Remove user from organization managers'
        delete ':id/managers/:user_id' do
          organization = Organization.find(params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(params[:user_id])
            user.remove_role(:manager, organization)
            status 204
          else
            status 403
          end
        end


        desc 'Add user to organization members'
        params do
          requires :user_id, type: String, desc: 'User id'
        end
        post ':id/members' do
          organization = Organization.find(params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(params[:user_id])
            user.add_role(:member, organization)
          else
            status 403
          end
        end


        desc 'Remove user from organization members'
        delete ':id/members/:user_id' do
          organization = Organization.find(params[:id])
          if organization.updatable_by?(current_user)
            user = User.find(params[:user_id])
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
