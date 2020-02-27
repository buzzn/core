
require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_status
  tee :check_precondition
  add :actions
  around :db_transaction
  tee :execute_pre_transistion
  add :persist, with: :'operations.action.update'
  tee :execute_post_transistion
  map :wrap_up

  include Import[
            accounting_service: 'services.accounting',
            mail_service: 'services.mail_service',
            billing_email_testmode: 'config.billing_email_testmode',
            billing_email_from: 'config.billing_email_from',
            billing_email_bcc:  'config.billing_email_bcc',
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
    when :documented
      unless params[:status].nil?
        case params[:status].to_sym
        when :documented
          subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
          result = Schemas::PreConditions::Billing::Update::DocumentedDocumented.call(subject)
          unless result.success?
            raise Buzzn::ValidationError.new(result.errors)
          end
        when :queued
          subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
          result = Schemas::PreConditions::Billing::Update::DocumentedQueued.call(subject)
          unless result.success?
            raise Buzzn::ValidationError.new(result.errors)
          end
        end
      end
    end
  end

  def actions(resource:, params:)
    billing = resource.object
    billing.transition_to(params.delete(:status))
  end

  def handle_action(resource:, params:, action:)
    user = resource.security_context.current_user
    billing = resource.object
    contract = billing.contract

    # transition may only continue if invariant are clean
    unless billing.invariant.errors.empty?
      raise Buzzn::ValidationError.new(billing.invariant.errors)
    end

    case action
    when :calculate
      total_amount = resource.object.total_amount_after_taxes
      # accounting is in decacents; 10dc = 1c
      total_amount_dc = (total_amount * 10).round(0)
      params[:accounting_entry] = accounting_service.book(user, contract, -1 * total_amount_dc.round, comment: "Billing #{resource.full_invoice_number}")

      if resource.object.localpool.billing_detail.automatic_abschlag_adjust
        last_payment = resource.object.contract.payments.order(:begin_date).last
        # FIXME adjust somehow to settings
        next_month = resource.object.end_date.at_beginning_of_month + 3.months
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
    when :reverse
      unless billing.accounting_entry.nil?
        comment = "Storno #{billing.full_invoice_number}"
        params[:accounting_entry] = accounting_service.book(user, contract, -1 * billing.accounting_entry.amount, comment: comment)
      end
      unless billing.adjusted_payment.nil?
        ap = billing.adjusted_payment
        billing.adjusted_payment = nil
        billing.save
        if ap.billings.count.zero?
          ap.destroy
        end
      end
    when :void
      billing.items.each(&:destroy)
    when :document
      generator = Pdf::Invoice.new(resource.object)
      generator.disable_cache
      filename="Stromrechnung_#{resource.object.full_invoice_number.tr('/', '-')}_#{Buzzn::Utils::Chronos.now.strftime('%Y%m%d_%H%M%S')}.pdf"
      document = generator.create_pdf_document(nil, filename).document
      unless resource.object.documents.where(:id => document.id).any?
        resource.object.documents << document
      end
    when :queue
      customer = resource.object.contract.customer
      email = if billing_email_testmode == '1'
                'dev@buzzn.net'
              else
                [customer.contact_email,
                 resource.object.localpool.owner.contact.email,
                 resource.object.localpool.owner.contact_email,
                 resource.object.localpool.owner.email].reject(&:nil?).first
              end
      if email.nil? || email.empty?
        raise Buzzn::ValidationError.new(customer: 'email invalid')
      end
      subject = 'Ihre Stromrechnung 2019'
      contractor_name = resource.object.contract.contractor.name
      text = %(Guten Tag,

im Auftrag Ihres Lokalen Stromgebers "#{contractor_name}" übermitteln wir Ihnen im
Anhang Ihre Stromrechnung 2019.

Bei Fragen oder sonstigem Feedback stehen wir Ihnen gerne zur Verfügung.

Vielen Dank, dass Sie People Power unterstützen, die Energiewende von unten.

Energiegeladene Grüße,

Ihr BUZZN Team

--

Philipp Oßwald
BUZZN – Teile Energie mit Deiner Gruppe.

T: 089-416171410
F: 089-416171499
team@buzzn.net
www.buzzn.net

BUZZN GmbH
Combinat 56
Adams-Lehmann-Straße 56
80797 München
Registergericht: Amtsgericht München
Registernummer: HRB 186043
Geschäftsführer: Justus Schütze
)
      document = resource.object.documents.order(:created_at).last

      mail_params = {:from => billing_email_from,
                     :to => email,
                     :subject => subject,
                     :text => text,
                     :bcc => billing_email_bcc,
                     :document_id => document.id}

      replay_to = [resource.object.localpool.owner.contact.email,
                   resource.object.localpool.owner.contact_email,
                   resource.object.localpool.owner.email].reject(&:nil?).first

      unless customer.contact_email.nil? && !replay_to.nil?
        mail_params[:replay_to] = replay_to
      end

      mail_service.deliver_billing_later(resource.object.id, mail_params)
    end
  end

  def execute_pre_transistion(resource:, params:, actions:)
    if actions.is_a?(Array)
      actions.select { |a| a[:at] == :pre }.collect { |a| handle_action(resource: resource, params: params, action: a[:action]) }
    end
  end

  def execute_post_transistion(resource:, params:, actions:, **)
    if actions.is_a?(Array)
      actions.select { |a| a[:at] == :post }.collect { |a| handle_action(resource: resource, params: params, action: a[:action]) }
    end
  end

  def wrap_up(persist:, **)
    persist
  end

end
