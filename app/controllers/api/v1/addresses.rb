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
          Address.readable_by(current_user)
        end

        desc 'Return address'
        params do
          requires :id, type: String, desc: 'Address id'
        end
        oauth2 :full
        get ':id' do
          address = Address.guarded_retrieve(current_user, permitted_params)
          render(address, meta: {
            updatable: address.updatable_by?(current_user),
            deletable: address.deletable_by?(current_user)
          })
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
          created_response(Address.guarded_create(current_user,
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
          address = Address.guarded_retrieve(current_user, permitted_params)
          address.guarded_update(current_user, permitted_params)
        end

        desc 'Delete address'
        params do
          requires :id, type: String, desc: 'Address id'
        end
        oauth2 :full
        delete ':id' do
          address = Address.guarded_retrieve(current_user, permitted_params)
          deleted_response(address.guarded_delete(current_user))
        end

      end
    end
  end
end
