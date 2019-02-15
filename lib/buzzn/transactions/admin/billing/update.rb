require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_status
  tee :check_precondition
  around :db_transaction
  tee :execute_transistion
  map :persist, with: :'operations.action.update'

  include Import[accounting_service: 'services.accounting']

  def schema
    Schemas::Transactions::Admin::Billing::Update
  end

  def check_status(resource:, params:)
    if !params[:status].nil? && !resource.object.allowed_transitions.map(&:to_s).include?(params[:status])
      # not allowed
      raise Buzzn::ValidationError.new(status: "transition from #{resource.object.status} to #{params[:status]} is not possible")
    end
  end

  def check_precondition(resource:, params:)
    case resource.object.status.to_sym
    when :calculated
      unless params[:status].nil?
        case params[:status].to_sym
        when :documented
          subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
          result = Schemas::PreConditions::Billing::Update::CalculatedDocumented.call(subject)
          unless result.success?
            raise Buzzn::ValidationError.new(result.errors)
          end
        end
      end
    end
  end

  def execute_transistion(resource:, params:)
    user = resource.security_context.current_user
    billing = resource.object
    contract = billing.contract
    action = billing.transition_to(params.delete(:status))
    # transition may only continue if invariant are clean
    unless billing.invariant.errors.empty?
      return
    end

    case action
    when :calculate
      total_amount = resource.object.total_amount_after_taxes
      # accounting is in decacents; 10dc = 1c
      total_amount_dc = total_amount * 10
      params[:accounting_entry] = accounting_service.book(user, contract, -1 * total_amount_dc.round, comment: "Billing #{resource.full_invoice_number}")

      if resource.object.localpool.billing_detail.automatic_abschlag_adjust
        last_payment = resource.object.contract.payments.order(:begin_date).last
        next_month = Date.today.at_beginning_of_month.next_month
        tariff = resource.object.contract.tariffs.at(next_month).order(:begin_date).last
        estimated_cents_per_month = tariff.cents_per_days(30, resource.object.daily_kwh_estimate)
        if last_payment.nil? ||
           # if begin_date is in the future we skip as it was manually adjusted
           # if price_cents is 0 we will also skip it
           (last_payment.begin_date < Date.today && last_payment.price_cents.positive?) &&
           # if we don't touch the treshold we also skip it
           (last_payment.price_cents-estimated_cents_per_month).abs >= resource.object.localpool.billing_detail.automatic_abschlag_threshold_cents
          # create new abschlag for next month
          rounded=100*(estimated_cents_per_month/100.round)
          payment = resource.object.contract.payments.create!(begin_date: next_month, price_cents: rounded, cycle: :monthly, energy_consumption_kwh_pa: 365*resource.object.daily_kwh_estimate, tariff: tariff)
          params[:adjusted_payment] = payment
        end
      end
    when :document
      generator = Pdf::Invoice.new(resource.object)
      generator.disable_cache
      document = generator.create_pdf_document.document
      unless resource.object.documents.where(:id => document.id).any?
        resource.object.documents << document
      end
    end
  end

end
