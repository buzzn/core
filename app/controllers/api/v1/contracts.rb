module API
  module V1
    class Contracts < Grape::API
      include API::V1::Defaults

      @@contract_params_names = [
        'tariff',
        'status',
        'customer_number',
        'contract_number',
        'signing_user',
        'terms',
        'power_of_attorney',
        'confirm_pricing_model',
        'commissioning',
        'mode',
        'organization_id',
      ]

      resource :contracts do

        desc 'Return all Contracts'
        get root: :contracts do
          doorkeeper_authorize! :public
          Contract.all
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
          doorkeeper_authorize! :admin
          @params = params.contract || params
          contract_params = Hash.new
          @@contract_params_names.each do |param_name|
            contract_params[param_name] = @params[param_name] if @params[param_name]
          end
          @contract = Contract.new(contract_params)
          @contract.contracting_party = current_user.contracting_party if current_user.contracting_party
          if @contract.organization.slug == 'buzzn-metering'
            @contract.username = 'team@localpool.de'
            @contract.password = 'Zebulon_4711'
          end
          if @contract.save!
            current_user.add_role :manager, @contract
            @contract.decorate
          end
        end


        desc 'Update a Contract'
        params do
          requires :id,           type: String, desc: 'Contract ID'
          # requires :mode,         type: String, desc: 'Contract description'
        end
        put do
          doorkeeper_authorize! :admin
          @params = params.contract || params
          @contract = Contract.find(@params.id)
          contract_params = Hash.new
          @@contract_params_names.each do |param_name|
            contract_params[param_name] = @params[param_name] if @params[param_name]
          end
          @contract.update_attributes(contract_params)
          return @contract
        end


        desc 'Delete a Contract'
        params do
          requires :id, type: String, desc: 'Contract ID'
        end
        delete ':id' do
          doorkeeper_authorize! :admin
          Contract.find(params[:id]).destroy
          status 200
        end


      end
    end
  end
end
