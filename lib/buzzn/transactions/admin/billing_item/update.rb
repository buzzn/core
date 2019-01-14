require_relative '../billing_item'
require_relative '../../../schemas/transactions/admin/billing_item/update'

class Transactions::Admin::BillingItem::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_valid
  tee :readings
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::BillingItem::Update
  end

  def check_valid(resource:, params:)
    if resource.status != 'open'
      raise Buzzn::ValidationError.new(:billing => ['billing is locked'])
    end
  end

  def readings(params:, **)
    begin_reading = Reading::Single.find(params.delete(:begin_reading_id))
    end_reading = Reading::Single.find(params.delete(:end_reading_id))
    if begin_reading.nil?
      raise Buzzn::ValidationError.new(:begin_reading => ['invalid id'])
    end
    if end_reading.nil?
      raise Buzzn::ValidationError.new(:end_reading => ['invalid id'])
    end
    if begin_reading.register != end_reading.register && begin_reading.register != resource.register
      raise Buzzn::ValidationError.new(:begin_reading => ['registers differ'])
    end
    params[:begin_reading] = begin_reading
    params[:end_reading]   = end_reading
  end

end
