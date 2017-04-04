module API
  module V1
    class ContractingParties < Grape::API
      include API::V1::Defaults

      resource 'contracting-parties' do

        desc 'Return all contracting parties'
        params do
        end
        oauth2 :full
        get do
          ContractingPartyResource.all
        end

        desc 'Return contractig party'
        params do
          requires :id, type: String, desc: 'ContractingParty ID'
        end
        oauth2 :full
        get ':id' do
          ContractingPartyResource.retrieve(current_user, permitted_params)
        end

        desc 'Update contracting party'
        params do
          requires :id, type: String, desc: 'ContractingParty ID'
          optional :sales_tax_number, type: Fixnum, desc: 'sales tax number'
          optional :tax_rate, type: Float, desc: 'tax rate'
          optional :tax_number, type: Fixnum, desc: 'tax number'
        end
        oauth2 :full
        patch ':id' do
          ContractingPartyResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end
      end
    end
  end
end
