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
          ContractingParty.all
        end

        desc 'Return contractig party'
        params do
          requires :id, type: String, desc: 'ContractingParty ID'
        end
        oauth2 :full
        get ':id' do
          contracting_party = ContractingParty.guarded_retrieve(current_user, permitted_params)
          render(contracting_party, meta: {
            updatable: contracting_party.updatable_by?(current_user),
            deletable: contracting_party.deletable_by?(current_user)
          })
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
          contracting_party = ContractingParty.guarded_retrieve(current_user, permitted_params)
          contracting_party.guarded_update(current_user, permitted_params)
        end
      end
    end
  end
end
