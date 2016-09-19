module API
  module V1
    class ContractingParties < Grape::API
      include API::V1::Defaults

      resource :contracting_parties do

        desc 'Return all contracting parties'
        params do
          optional :per_page, type: Fixnum, desc: 'Entries per Page', default: 10, max: 100
          optional :page, type: Fixnum, desc: 'Page number', default: 1
        end
        paginate
        oauth2 :full
        get do
          paginated_response(ContractingParty.all)
        end

        desc 'Return contractig party'
        params do
          requires :id, type: String, desc: 'ContractingParty id'
        end
        oauth2 :full
        get ':id' do
          contracting_party = ContractingParty.find(permitted_params[:id])
          if contracting_party.readable_by?(current_user)
            contracting_party
          else
            status 403
          end
        end

        desc 'Create contracting party'
        params do
          requires :legal_entity, type: String, values: ContractingParty.legal_entities.map(&:to_s)
          optional :sales_tax_number, type: Fixnum
          optional :tax_rate, type: Float
          optional :tax_number, type: Fixnum
          optional :organization_id, type: String
          optional :metering_point_id, type: String
          optional :user_id, type: String
        end
        oauth2 :full
        post do
          if ContractingParty.creatable_by?(current_user)
            contracting_party = ContractingParty.create!(permitted_params)
            created_response(contracting_party)
          else
            status 403
          end
        end

        desc 'Update contracting party'
        params do
          requires :id, type: String, desc: 'ContractingParty id'
          optional :legal_entity, type: String, values: ContractingParty.legal_entities.map(&:to_s)
          optional :sales_tax_number, type: Fixnum
          optional :tax_rate, type: Float
          optional :tax_number, type: Fixnum
          optional :organization_id, type: String
          optional :metering_point_id, type: String
          optional :user_id, type: String
        end
        oauth2 :full
        patch ':id' do
          contracting_party = ContractingParty.find(permitted_params[:id])
          if contracting_party.updatable_by?(current_user)
            contracting_party.update!(permitted_params)
            contracting_party
          else
            status 403
          end
        end

        desc 'Delete contracting party'
        params do
          requires :id, type: String, desc: 'ContractingParty id'
        end
        oauth2 :full
        delete ':id' do
          contracting_party = ContractingParty.find(permitted_params[:id])
          if contracting_party.deletable_by?(current_user)
            contracting_party.destroy
            status 204
          else
            status 403
          end
        end

      end
    end
  end
end
