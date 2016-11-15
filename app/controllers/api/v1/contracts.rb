module API
  module V1
    class Contracts < Grape::API
      include API::V1::Defaults

      resource :contracts do

        desc 'Return all Contracts'
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Contract.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :full
        get do
          paginated_response(Contract.filter(permitted_params[:filter]).readable_by(current_user))
        end

        desc 'Return a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        oauth2 :simple, :full
        get ':id' do
          Contract.guarded_retrieve(current_user, permitted_params)
        end


        desc 'Create a Contract'
        params do
          requires :mode,                     type: String,  desc: 'Contract description'
          optional :status,                   type: String,  desc: 'Status'
          optional :customer_number,          type: String,  desc: 'Customer number'
          optional :contract_number,          type: String,  desc: 'Contract number'
          optional :signing_user,             type: String,  desc: 'Signing user'
          requires :terms,                    type: Boolean, desc: 'Terms'
          requires :power_of_attorney,        type: Boolean, desc: 'Power of attorney'
          requires :confirm_pricing_model,    type: Boolean, desc: 'Confirm pricing model'
          requires :commissioning,            type: Date,    desc: 'Commissioning'
          optional :register_id,        type: String,  desc: 'Register ID'
          optional :other_contract,           type: Boolean, desc: 'Has other contract'
          optional :move_in,                  type: Boolean, desc: 'Move in'
          optional :beginning,                type: Date, desc: 'Begin date'
          optional :authorization,            type: Boolean, desc: 'Authorization'
          optional :feedback,                 type: String, desc: 'Feedback'
          optional :attention_by,             type: String, desc: 'Attention by'
          # TODO: Should username/password be here?
          optional :username,               type: String,  desc: 'Username'
          optional :password,               type: String,  desc: 'Password'
          optional :contract_owner_id,      type: String,  desc: 'ContractingParty Owner ID'
          optional :contract_beneficiary_id,type: String,  desc: 'ContractingParty Beneficiary ID'
        end
        oauth2 :full, :smartmeter
        post do
          contract = Contract.guarded_create(current_user, permitted_params)
          created_response(contract)
        end


        desc 'Update a Contract'
        params do
          requires :id,                       type: String, desc: 'Contract ID'
          optional :mode,                     type: String, desc: 'Contract description'
          optional :organization_id,          type: String, desc: 'Organization id'
          optional :tariff,                   type: String, desc: 'Tariff'
          optional :status,                   type: String, desc: 'Status'
          optional :customer_number,          type: String, desc: 'Customer number'
          optional :contract_number,          type: String, desc: 'Contract number'
          optional :signing_user,             type: String, desc: 'Signing user'
          optional :terms,                    type: Boolean, desc: 'Terms'
          optional :power_of_attorney,        type: Boolean, desc: 'Power of attorney'
          optional :confirm_pricing_model,    type: Boolean, desc: 'Confirm pricing model'
          optional :commissioning,            type: Date, desc: 'Commissioning'
          optional :retailer,                 type: Boolean, desc: 'Is a Retailer'
          optional :price_cents_per_kwh,      type: Float, desc: 'Price per KWH incents'
          optional :price_cents_per_month,    type: Integer, desc: 'Price per month in cents'
          optional :discount_cents_per_month, type: Integer, desc: 'Discount per month in cents'
          optional :other_contract,           type: Boolean, desc: 'Has other contract'
          optional :move_in,                  type: Boolean, desc: 'Move in'
          optional :beginning,                type: Date, desc: 'Begin date'
          optional :authorization,            type: Boolean, desc: 'Authorization'
          optional :feedback,                 type: String, desc: 'Feedback'
          optional :attention_by,             type: String, desc: 'Attention by'
          optional :username,                 type: String, desc: 'Username'
          optional :password,                 type: String, desc: 'Password'
          optional :contract_owner_id,      type: String,  desc: 'ContractingParty Owner ID'
          optional :contract_beneficiary_id,type: String,  desc: 'ContractingParty Beneficiary ID'
        end
        oauth2 :full
        patch ':id' do
          contract = Contract.guarded_retrieve(current_user, permitted_params)
          contract.guarded_update(current_user, permitted_params)
        end


        desc 'Delete a Contract'
        params do
          requires :id, type: String, desc: 'Contract ID'
        end
        oauth2 :full
        delete ':id' do
          contract = Contract.guarded_retrieve(current_user, permitted_params)
          deleted_response(contract.guarded_delete(current_user))
        end


      end
    end
  end
end
