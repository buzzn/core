require_relative '../billing_item'
require_relative '../../../schemas/transactions/admin/billing_item/update'

class Transactions::Admin::BillingItem::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_valid
  tee :assign_begin_reading
  tee :assign_end_reading
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::BillingItem::Update
  end

  def check_valid(resource:, params:)
    if resource.status != 'open'
      raise Buzzn::ValidationError.new(:billing => ['billing is locked'])
    end
  end

  def assign_begin_reading(params:, **)
    unless params[:begin_reading_id].nil?
      begin
        begin_reading = Reading::Single.find(params.delete(:begin_reading_id))
      rescue ActiveRecord::RecordNotFound
        raise Buzzn::ValidationError.new(:begin_reading => ['invalid id'])
      end
      params[:begin_reading] = begin_reading
    end
  end

  def assign_end_reading(params:, **)
    unless params[:end_reading_id].nil?
      begin
        end_reading = Reading::Single.find(params.delete(:end_reading_id))
      rescue ActiveRecord::RecordNotFound
        raise Buzzn::ValidationError.new(:end_reading => ['invalid id'])
      end
      params[:end_reading] = end_reading
    end
  end

end
