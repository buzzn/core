require_relative '../localpool'
require_relative '../../../../schemas/transactions/admin/contract/localpool_power_taker/assign_tariffs'

class Transactions::Admin::Contract::Localpool::AssignTariffs < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  add :fetched_tariffs
  around :db_transaction
  add :assign_tariffs
  map :wrap_up, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::AssignTariffs
  end

  def fetched_tariffs(params:, resource:, **)
    begin
      tariffs = Contract::Tariff.find(params[:tariff_ids])
      tariffs.each do |tariff|
        if tariff.group != resource.object.localpool
          raise Buzzn::ValidationError.new(tariffs: ['one or more tariffs do not belong to this group'])
        end
      end
    rescue ActiveRecord::RecordNotFound
      raise Buzzn::ValidationError.new(tariffs: ['one or more tariffs do not exist'])
    end
  end

  def assign_tariffs(params:, resource:, fetched_tariffs:, **)
    # validate that we are not deleting some tariff that is already used
    # in a BillingItem
    # FIXME move to invariant
    used_tariffs = resource.object.billing_items.collect { |x| x.tariff }.uniq
    # check whether the already used tariffs are still included in the assignment
    unless fetched_tariffs & used_tariffs == used_tariffs
      raise Buzzn::ValidationError.new(tariffs: ['tariffs are already used in billings'])
    end
    # check whether a tariff would be valid for an already billed item
    new_tariffs = fetched_tariffs - resource.object.tariffs
    new_tariffs.each do |tariff|
      if resource.object.billing_items.end_after_or_same(tariff.begin_date).any?
        raise Buzzn::ValidationError.new(tariffs: ["tariff id #{tariff.id} is active for an already present billing item"])
      end
    end

    params[:tariffs] = fetched_tariffs
    params.delete(:tariff_ids)
  end

end
