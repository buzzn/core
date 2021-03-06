require_relative '../admin_roda'

module Admin
  class ContractRoda < BaseRoda

    include Import.args[:env,
                        document: 'transactions.admin.contract.document',
                        create_processing: 'transactions.admin.contract.localpool.create_processing',
                        create_third_party: 'transactions.admin.contract.localpool.create_third_party',
                        update_processing: 'transactions.admin.contract.localpool.update_processing',
                        assign_tariffs: 'transactions.admin.contract.localpool.assign_tariffs',
                        create_power_taker_assign: 'transactions.admin.contract.localpool.create_power_taker_assign',
                        create_power_taker_with_person: 'transactions.admin.contract.localpool.create_power_taker_with_person',
                        create_power_taker_with_organization: 'transactions.admin.contract.localpool.create_power_taker_with_organization',
                        update_power_taker: 'transactions.admin.contract.localpool.update_power_taker',
                        update_third_party: 'transactions.admin.contract.localpool.update_third_party',
                        create_metering_point_operator: 'transactions.admin.contract.localpool.create_metering_point_operator',
                        update_metering_point_operator: 'transactions.admin.contract.localpool.update_metering_point_operator',
                        bank_account_assign: 'transactions.admin.bank_account.assign',
                        update_nested_person: 'transactions.admin.generic.update_nested_person',
                        update_nested_organization: 'transactions.admin.generic.update_nested_organization',
                        delete_gap_contract: 'transactions.admin.contract.localpool.delete_gap_contract',
                        deliver_tarrif_change_letter_service: 'services.deliver_tarrif_change_letter_service'
                       ]

    plugin :shared_vars
    plugin :param_matchers

    PARENT = :contract

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]
      contracts = localpool.contracts
      localpool_processing_contracts = localpool.localpool_processing_contracts
      localpool_third_party_contracts = localpool.localpool_third_party_contracts
      localpool_power_taker_contracts = localpool.localpool_power_taker_contracts
      metering_point_operator_contracts = localpool.metering_point_operator_contracts

      r.on :id do |id|

        shared[PARENT] = contract = contracts.retrieve(id)

        r.get! do
          contract
        end

        r.patch! do
          case contract
          when Contract::LocalpoolProcessingResource
            update_processing.(resource: contract, params: r.params)
          when Contract::LocalpoolPowerTakerResource
            update_power_taker.(resource: contract, params: r.params)
          when Contract::LocalpoolThirdPartyResource
            update_third_party.(resource: contract, params: r.params)
          when Contract::MeteringPointOperatorResource
            update_metering_point_operator.(resource: contract, params: r.params)
          else
            r.response.status = 400
          end
        end

        r.delete! do
          case contract
          when Contract::LocalpoolGapContractResource
            delete_gap_contract.(resource: contract) 
          else
            r.response.status = 400
            raise Buzzn::ValidationError.new(contract: ['must be gap contract'])
          end
        end

        r.get! 'contractor' do
          contract.contractor!
        end

        r.on 'send-tariff-change-letter' do
          r.on :id do |document_id|
            r.get! do
              deliver_tarrif_change_letter_service.deliver_tariff_change_letter(localpool, contract, document_id)
              {message: "Sent tariff change letter #{contract.contact.name}"}
            end
          end
        end

        r.get!('contractor') { contract.contractor! }

        r.get!('customer') { contract.customer! }

        r.patch!('customer-bank-account') do
          bank_account_assign.(resource: contract, params: r.params, attribute: :customer_bank_account, person_or_org: :customer)
        end

        r.patch!('contractor-bank-account') do
          bank_account_assign.(resource: contract, params: r.params, attribute: :contractor_bank_account, person_or_org: :contractor)
        end

        r.patch!('customer-person') do
          case contract
          when Contract::LocalpoolPowerTakerResource
            update_nested_person.(resource: contract.customer, params: r.params)
          else
            r.response.status = 400
          end
        end

        r.patch!('customer-organization') do
          case contract
          when Contract::LocalpoolPowerTakerResource
            update_nested_organization.(resource: contract.customer, params: r.params)
          else
            r.response.status = 400
          end
        end

        r.on 'documents' do

          r.on 'generate' do
            # Dear God, I know I am a sinner and I as for your forgiveness.
            if localpool.contact.id == 868 and r.params['template'] == 'tariff_change_letter'
              r.params['template'] = "tariff_change_letter_isarwatt"
            end
            r.post! { document.(resource: contract, params: r.params) }
            r.others!
          end

          shared[:documents] = contract.documents
          r.run DocumentRoda
        end

        r.on 'tariffs' do
          r.patch! do
            case contract
            when Contract::LocalpoolPowerTakerResource
              assign_tariffs.(resource: contract, params: r.params)

            else
              r.response.status = 400
            end
          end
          r.get! do
            # FIXME remove in favor of tree include?
            contract.contexted_tariffs
          end
          r.others!
        end

        r.on 'billings' do
          shared[:billings] = contract.billings
          shared[:parent_contract] = contract.object
          r.run BillingRoda
        end

        r.on 'comments' do
          shared[:comments] = contract.comments
          r.run CommentRoda
        end

        r.on 'accounting' do
          shared[:contract] = contract
          r.run AccountingRoda
        end

        r.on 'payments' do
          shared[:payments] = contract.payments
          r.run PaymentRoda
        end

      end

      r.get! do
        case r.params['type'].to_s
        when 'contract_localpool_processing'
          localpool_processing_contracts
        when 'contract_localpool_power_taker'
          localpool_power_taker_contracts
        when 'contract_localpool_third_party'
          localpool_third_party_contracts
        when 'contract_metering_point_operator'
          metering_point_operator_contracts
        else
          contracts
        end
      end

      r.post!(:param=>'type') do |type|
        case type.to_s
        when 'contract_localpool_processing'
          create_processing.(resource: localpool_processing_contracts, params: r.params, localpool: localpool)
        when 'contract_metering_point_operator'
          create_metering_point_operator.(resource: metering_point_operator_contracts, params: r.params, localpool: localpool)
        when 'contract_localpool_third_party'
          create_third_party.(resource: localpool_third_party_contracts, params: r.params, localpool: localpool)
        when 'contract_localpool_power_taker'
          # we have 3 cases here:
          # assign with an id
          # create with an organization as customer
          # create with a  person as customer
          if r.params['customer'].nil?
            # TODO error
            r.response.status = 422
            raise Buzzn::ValidationError.new(customer: ['must be filled'])
          else
            if !r.params['customer']['id'].nil?
              create_power_taker_assign.(resource: localpool_power_taker_contracts, params: r.params, localpool: localpool)
            elsif r.params['customer']['type'] == 'organization'
              create_power_taker_with_organization.(resource: localpool_power_taker_contracts, params: r.params, localpool: localpool)
            else # default to person
              begin
                create_power_taker_with_person.(resource: localpool_power_taker_contracts, params: r.params, localpool: localpool)
              rescue => exception
              end
              
            end
          end
        else
          r.response.status = 400
          # FIXME empty response, convert to raise Buzzn::InvalidFooError
          ""
        end
      end

      # without a type
      r.post! do
        r.response.status = 400
        # FIXME empty response, convert to raise Buzzn::InvalidFooError
        ""
      end

    end

  end
end
