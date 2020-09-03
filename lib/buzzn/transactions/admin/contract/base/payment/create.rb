require_relative '../payment'

module Transactions::Admin::Contract::Base::Payment
  class Create < Transactions::Base

    validate :schema
    check :authorize, with: 'operations.authorization.create'
    add :fetch_tariff
    add :current_vat
    tee :calculate_price
    around :db_transaction
    map :create_payment, with: 'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::Payment::Create
    end

    def fetch_tariff(params:, **)
      begin
        if params[:tariff_id]
          t = Contract::Tariff.find(params.delete(:tariff_id))
          params[:tariff] = t
          t
        else
          nil
        end
      rescue ActiveRecord::RecordNotFound
        raise Buzzn::ValidationError.new({tariff: ['tariff does not exist']})
      end
    end

    def current_vat(**)
      Vat.current.amount
    end

    def calculate_price(params:, fetch_tariff:, **)
      unless fetch_tariff.nil?
        price_cents = case params[:cycle]
                      when 'monthly'
                        fetch_tariff.cents_per_days(30, params[:energy_consumption_kwh_pa] / 365.0) * current_vat
                      when 'yearly'
                        fetch_tariff.cents_per_days(365, params[:energy_consumption_kwh_pa] / 365.0)* current_vat
                      end
        params[:price_cents] = (price_cents/100.00).round*100
      end
    end

    def create_payment(params:, resource:, **)
      Contract::PaymentResource.new(
        *super(resource, params)
      )
    end

  end
end
