# coding: utf-8
require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_status
  tee :check_precondition
  add :action
  around :db_transaction
  tee :execute_pre_transistion
  add :persist, with: :'operations.action.update'
  tee :execute_post_transistion
  map :wrap_up

  include Import[
            fixed_email: 'config.fixed_email',
            accounting_service: 'services.accounting',
            mail_service: 'services.mail_service',
            powertaker_v1_from: 'config.powertaker_v1_from',
            powertaker_v1_bcc: 'config.powertaker_v1_bcc',
          ]

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

  def action(resource:, params:)
    billing = resource.object
    billing.transition_to(params.delete(:status))
  end

  def execute_pre_transistion(resource:, params:, action:)
    user = resource.security_context.current_user
    billing = resource.object
    contract = billing.contract
    # transition may only continue if invariant are clean
    unless billing.invariant.errors.empty?
      return
    end

    case action
    when :calculate
      total_amount = resource.object.total_amount_after_taxes
      # accounting is in decacents; 10dc = 1c
      total_amount_dc = (total_amount * 10).round(0)
      params[:accounting_entry] = accounting_service.book(user, contract, -1 * total_amount_dc.round, comment: "Billing #{resource.full_invoice_number}")

      if resource.object.localpool.billing_detail.automatic_abschlag_adjust
        last_payment = resource.object.contract.payments.order(:begin_date).last
        next_month = resource.object.end_date.at_beginning_of_month + 2.months
        tariff = resource.object.contract.tariffs.at(next_month).order(:begin_date).last
        estimated_cents_per_month = tariff.cents_per_days_after_taxes(30.42, resource.object.daily_kwh_estimate)
        if last_payment.nil? ||
           # if begin_date is in the future we skip as it was manually adjusted
           # if price_cents is 0 we will also skip it
           (last_payment.begin_date < Date.today && !last_payment.price_cents.negative?) &&
           # if we don't touch the treshold we also skip it
           (last_payment.price_cents-estimated_cents_per_month).abs >= resource.object.localpool.billing_detail.automatic_abschlag_threshold_cents
          # create new abschlag for next month
          rounded=100*(estimated_cents_per_month/100).round
          payment = resource.object.contract.payments.where(begin_date: next_month).first || resource.object.contract.payments.create!(begin_date: next_month, price_cents: rounded, cycle: :monthly, energy_consumption_kwh_pa: (365*resource.object.daily_kwh_estimate).round, tariff: tariff)
          params[:adjusted_payment] = payment
        end
      end
    when :document
      generator = Pdf::Invoice.new(resource.object)
      generator.disable_cache
      filename="Stromrechnung_#{resource.object.full_invoice_number.gsub('/','-')}_#{Buzzn::Utils::Chronos.now.strftime('%Y%m%d_%H%M%S')}.pdf"
      document = generator.create_pdf_document(nil, filename).document
      unless resource.object.documents.where(:id => document.id).any?
        resource.object.documents << document
      end
    end
  end

  def execute_post_transistion(resource:, params:, action:, **)
    case action
    when :queue
      customer = resource.object.contract.customer
      email = if fixed_email.nil? || fixed_email.empty?
                case customer
                when Person
                  customer.email
                when Organization::Base
                  (!customer.contact.nil? && !customer.contact.email.empty?) ? customer.contact.email : customer.email
                end
              else
                fixed_email
              end
      if email.nil? || email.empty?
        raise Buzzn::ValidationError.new(customer: 'email invalid')
      end
      subject = 'Ihre Stromrechnung 2018'
      contractor_name = resource.object.contract.contractor.name
      text = %Q(Guten Tag,

im Auftrag Ihres Lokalen Stromgebers "#{contractor_name}" übermitteln wir Ihnen im
Anhang Ihre Stromrechnung 2018.

Bei Fragen oder sonstigem Feedback stehen wir Ihnen gerne zur Verfügung.

Vielen Dank, dass Sie People Power unterstützen, die Energiewende von unten.

Energiegeladene Grüße,

Ihr BUZZN Team
)
      document = resource.object.documents.order(:created_at).last
      mail_service.deliver_billing_later(resource.object.id, :from => powertaker_v1_from,
                                                             :to => email,
                                                             :subject => subject,
                                                             :text => text,
                                                             :bcc => powertaker_v1_bcc,
                                                             :document_id => document.id)
    end
  end

  def wrap_up(persist:, **)
    persist
  end

end
