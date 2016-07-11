module API
  module V1
    class Contracts < Grape::API
      include API::V1::Defaults

      resource :contracts do

        desc 'Return all Contracts'
        paginate(per_page: per_page=10)
        get do
          doorkeeper_authorize! :manager
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = Contract.all.page(@page).per_page(@per_page).total_pages
          paginate(render(Contract.all, meta: { total_pages: @total_pages }))
        end

        desc 'Return a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        get ':id' do
          doorkeeper_authorize! :public
          Contract.find(params[:id])
        end


        desc 'Create a Contract'
        params do
          requires :mode,                   type: String, desc: 'Contract description'
          requires :organization_id,        type: String, desc: 'Organization id'
          requires :tariff,                 type: String, desc: 'Tariff'
          requires :status,                 type: String, desc: 'Status'
          requires :customer_number,        type: String, desc: 'Customer number'
          requires :contract_number,        type: String, desc: 'Contract number'
          requires :signing_user,           type: String, desc: 'Signing user'
          requires :terms,                  type: Boolean, desc: 'Terms'
          requires :power_of_attorney,      type: Boolean, desc: 'Power of attorney'
          requires :confirm_pricing_model,  type: Boolean, desc: 'Confirm pricing model'
          requires :commissioning,          type: Date, desc: 'Commissioning'
        end
        post do
          doorkeeper_authorize! :manager
          @params = declared(params, include_missing: false).contract || declared(params, include_missing: false)
          @contract = Contract.new(@params)
          @contract.contracting_party = current_user.contracting_party if current_user.contracting_party
          if @contract.save!
            current_user.add_role :manager, @contract
          end
          @contract
        end


        desc 'Update a Contract'
        params do
          requires :id,           type: String, desc: 'Contract ID'
          optional :mode,                   type: String, desc: 'Contract description'
          optional :organization_id,        type: String, desc: 'Organization id'
          optional :tariff,                 type: String, desc: 'Tariff'
          optional :status,                 type: String, desc: 'Status'
          optional :customer_number,        type: String, desc: 'Customer number'
          optional :contract_number,        type: String, desc: 'Contract number'
          optional :signing_user,           type: String, desc: 'Signing user'
          optional :terms,                  type: Boolean, desc: 'Terms'
          optional :power_of_attorney,      type: Boolean, desc: 'Power of attorney'
          optional :confirm_pricing_model,  type: Boolean, desc: 'Confirm pricing model'
          optional :commissioning,          type: Date, desc: 'Commissioning'
        end
        put do
          doorkeeper_authorize! :manager
          @params = declared(params, include_missing: false).contract || declared(params, include_missing: false)
          @contract = Contract.find(@params.id)
          @params.delete('id')
          @contract.update_attributes(@params)
          return @contract
        end


        desc 'Delete a Contract'
        params do
          requires :id, type: String, desc: 'Contract ID'
        end
        delete ':id' do
          doorkeeper_authorize! :manager
          Contract.find(params[:id]).destroy
          status 200
        end


      end
    end
  end
end
