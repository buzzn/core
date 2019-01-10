require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/assign_gap_contract_tariffs'

module Transactions::Admin::Localpool

  class AssignGapContractTariffs < Transactions::Base

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    add :fetched_tariffs
    around :db_transaction
    add :assign_tariffs
    map :wrap_up, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Localpool::AssignGapContractTariffs
    end

    def fetched_tariffs(params:, resource:, **)
      begin
        tariffs = Contract::Tariff.find(params[:tariff_ids])
        tariffs.each do |tariff|
          if tariff.group != resource.object
            raise Buzzn::ValidationError.new(tariffs: ['one or more tariffs do not belong to this group'])
          end
        end
      rescue ActiveRecord::RecordNotFound
        raise Buzzn::ValidationError.new(tariffs: ['one or more tariffs do not exist'])
      end
    end

    def assign_tariffs(params:, resource:, fetched_tariffs:, **)
      params[:gap_contract_tariffs] = fetched_tariffs
      params.delete(:tariff_ids)
    end

  end

end
