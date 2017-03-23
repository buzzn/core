module API
  module V1
    class Addresses < Grape::API
      include API::V1::Defaults

      resource :addresses do

        desc 'Return all addresses'
        params do
        end
        oauth2 :full
        get do
          AddressResource.all(current_user)
        end

        desc 'Return address'
        params do
          requires :id, type: String, desc: 'Address id'
        end
        oauth2 :full
        get ':id' do
          AddressResource.retrieve(current_user, permitted_params)
        end

        desc 'Create address'
        params do
          requires :street_name, type: String, desc: 'street name'
          requires :street_number, type: String, desc: 'street number'
          requires :city, type: String, desc: 'city'
          requires :state, type: String, values: Address.states(&:to_s), desc: 'state'
          requires :zip, type: String, desc: 'zip'
          requires :country, type: String, desc: 'country'
          optional :addition, type: String, desc: 'additional info'
        end
        oauth2 :full
        post do
          created_response(AddressResource.create(current_user,
                                                  permitted_params))
        end

        desc 'Update address'
        params do
          requires :id, type: String, desc: 'Address id'
          optional :street_name, type: String, desc: 'street name'
          optional :street_number, type: String, desc: 'street number'
          optional :city, type: String, desc: 'city'
          optional :state, type: String, values: Address.states(&:to_s), desc: 'state'
          optional :zip, type: String, desc: 'zip'
          optional :country, type: String, desc: 'country'
          optional :addition, type: String, desc: 'additional info'
        end
        oauth2 :full
        patch ':id' do
          AddressResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end

        desc 'Delete address'
        params do
          requires :id, type: String, desc: 'Address id'
        end
        oauth2 :full
        delete ':id' do
          deleted_response(AddressResource
                            .retrieve(current_user, permitted_params)
                            .delete)
        end

      end
    end
  end
end
