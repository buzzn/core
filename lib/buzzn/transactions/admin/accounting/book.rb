require_relative '../accounting'

class Transactions::Admin::Accounting::Book < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  tee :set_user
  around :db_transaction
  map :wrap_up, with: :'operations.action.create_item'

  include Import[accounting_service: 'services.accounting']

  def schema
    Schemas::Transactions::Accounting::Book
  end

  def set_user(params:, resource:, **)
    security = resource.security_context
    params[:booked_by] = security.current_user
  end

  def wrap_up(params:, resource:)
    Accounting::EntryResource.new(
      *super(resource, params)
    )
  end

end
