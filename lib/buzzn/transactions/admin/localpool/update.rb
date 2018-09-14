require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :create_or_update_address, with: :'operations.action.create_or_update_address'
  tee :create_or_update_billing_detail, with: :'operations.action.update'
  map :update_localpool, with: :'operations.action.update'

  def create_or_update_billing_detail(params:, resource:, **)
    if params[:billing_detail]
      if resource.billing_detail.nil?
        params[:billing_detail] = BillingDetail.create!(params[:billing_detail])
      else
        super(params: params.delete(:billing_detail), resource: resource.billing_detail)
      end
    end
  end

  def schema(resource:, **)
    Schemas::Transactions::Admin::Localpool.update_for(resource)
  end

end
