module API
  module V1
    class Organizations < Grape::API
      include API::V1::Defaults
      
      resource :organizations do

        before do
          doorkeeper_authorize!
        end
        
        desc "Return all organizations"
        paginate(per_page: per_page=10)
        get root: :organizations do
          if Organization.readable_by?(current_user)
            per_page     = params[:per_page] || per_page
            page         = params[:page] || 1
            total_pages  = Organization.all.page(page).per_page(per_page).total_pages
            paginate(render(Organization.all, meta: { total_pages: total_pages }))
          else
            status 403
          end
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

      end
    end
  end
end
