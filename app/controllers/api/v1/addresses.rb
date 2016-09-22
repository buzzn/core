module API
  module V1
    class Addresses < Grape::API
      include API::V1::Defaults

      resource :addresses do

        desc 'Return all addresses'
        params do
          optional :per_page, type: Fixnum, desc: 'Entries per Page', default: 10, max: 100
          optional :page, type: Fixnum, desc: 'Page number', default: 1
        end
        paginate
        oauth2 :full
        get do
          paginated_response(Address.readable_by(current_user))
        end

        desc 'Return address'
        params do
          requires :id, type: String, desc: 'Address id'
        end
        oauth2 :full
        get ':id' do
          address = Address.find(permitted_params[:id])
          if address.readable_by?(current_user)
            address
          else
            status 403
          end
        end

        desc 'Create address'
        params do
          requires :street_name, type: String
          requires :street_number, type: String
          requires :city, type: String
          requires :state, type: String, values: Address.states(&:to_s)
          requires :zip, type: Fixnum
          requires :country, type: String
          optional :addition, type: String
        end
        oauth2 :full
        post do
          if Address.creatable_by?(current_user)
            address = Address.create!(permitted_params)
            created_response(address)
          else
            status 403
          end
        end

        desc 'Update address'
        params do
          requires :id, type: String, desc: 'Address id'
          optional :street_name, type: String
          optional :street_number, type: String
          optional :city, type: String
          optional :state, type: String, values: Address.states(&:to_s)
          optional :zip, type: Fixnum
          optional :country, type: String
          optional :addition, type: String
        end
        oauth2 :full
        patch ':id' do
          address = Address.find(permitted_params[:id])
          if address.updatable_by?(current_user)
            address.update!(permitted_params)
            address
          else
            status 403
          end
        end

        desc 'Delete address'
        params do
          requires :id, type: String, desc: 'Address id'
        end
        oauth2 :full
        delete ':id' do
          address = Address.find(permitted_params[:id])
          if address.deletable_by?(current_user)
            address.destroy
            status 204
          else
            status 403
          end
        end

      end
    end
  end
end
