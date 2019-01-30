require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  around :db_transaction
  tee :create_address, with: :'operations.action.create_address'
  tee :create_billing_detail
  map :create_localpool, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Localpool::Create
  end

  def create_billing_detail(params:, **)
    params[:billing_detail] = if params[:billing_detail]
      params[:billing_detail] = BillingDetail.create!(params[:billing_detail])
    else
      params[:billing_detail] = BillingDetail.create!(BillingDetail.defaults)
    end
  end

  def create_localpool(params:, resource:)
    Admin::LocalpoolResource.new(
      *super(resource, params)
    )
  end

end
