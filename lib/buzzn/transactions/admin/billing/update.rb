
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

  def check_status(resource:, params:, **)
    if !params[:status].nil? && !resource.object.allowed_transitions.map(&:to_s).include?(params[:status])
      # not allowed
      raise Buzzn::ValidationError.new({status: ["transition from #{resource.object.status} to #{params[:status]} is not possible"]}, resource.object)
    end
  end

  def check_precondition(resource:, params:, **)
    case resource.object.status.to_sym
    when :calculated
      unless params[:status].nil?
        case params[:status].to_sym
        when :documented
          subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
          result = Schemas::PreConditions::Billing::Update::CalculatedDocumented.call(subject)
          unless result.success?
            raise Buzzn::ValidationError.new(result.errors, resource.object)
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
            raise Buzzn::ValidationError.new(result.errors, resource.object)
          end
        when :queued
          subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
          result = Schemas::PreConditions::Billing::Update::DocumentedQueued.call(subject)
          unless result.success?
            raise Buzzn::ValidationError.new(result.errors, resource.object)
          end
        end
      end
    end
  end

  def actions(resource:, params:, vat:)
    billing = resource.object
    billing.transition_to(params.delete(:status))
  end

  def handle_action(resource:, params:, action:, vat:)
    user = resource.security_context.current_user
    billing = resource.object
    contract = billing.contract

    # transition may only continue if invariant are clean
    unless billing.invariant.errors.empty?
      raise Buzzn::ValidationError.new(billing.invariant.errors, resource.object)
    end

    receiver_person = resource.object.contract.contact
    case action
    when :calculate
      total_amount = resource.object.total_amount_after_taxes
      # accounting is in decacents; 10dc = 1c
      total_amount_dc = (total_amount * 10).round(0)
      params[:accounting_entry] = accounting_service.book(user, contract, -1 * total_amount_dc.round, comment: "Billing #{resource.full_invoice_number}")
      
      if resource.object.localpool.billing_detail.automatic_abschlag_adjust
        last_payment = resource.object.contract.payments.order(:begin_date).last
        # FIXME adjust somehow to settings
        next_month = resource.object.end_date.at_beginning_of_month + 3.months # Todo move this to settings begin date ob billing_detail
        tariff = resource.object.contract.tariffs.at(next_month).order(:begin_date).last
        estimated_cents_per_month = tariff.cents_per_days(30.42, resource.object.daily_kwh_estimate) * vat.amount
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
      filename="Stromrechnung_#{resource.object.full_invoice_number.tr('/', '-')}_#{Buzzn::Utils::Chronos.now.strftime('%Y%m%d_%H%M%S')}_#{receiver_person&.last_name}.pdf"
      document = generator.create_pdf_document(nil, filename).document
      unless resource.object.documents.where(:id => document.id).any?
        resource.object.documents << document
      end
    when :queue
      email = if billing_email_testmode == '1'
                'dev@buzzn.net'
              else
                [receiver_person.email,
                 resource.object.localpool.contact.email,
                ].reject(&:nil?).first
              end
      if email.nil? || email.empty?
        raise Buzzn::ValidationError.new({customer: ['email invalid']}, resource.object)
      end
      subject = "Lokale Energiegruppe #{resource.object.localpool.name} - Ihre Stromrechnung #{Buzzn::Utils::Chronos.now.prev_year.strftime('%Y')}"

      if receiver_person.nil?
        anrede = 'Sehr geehrte Damen und Herren'
      else
        if receiver_person.prefix == 'male'
          anrede = "Sehr geehrter Herr #{receiver_person.last_name}"
        elsif receiver_person.prefix == 'female'
          anrede = "Sehr geehrte Frau #{receiver_person.last_name}"
        else
          anrede = "Guten Tag Frau/Herr #{receiver_person.last_name}"
        end
      end

      text = %(#{anrede},

im Auftrag Ihres Lokalen Stromgebers "#{resource.object.localpool.owner.name}" übermitteln wir Ihnen im
Anhang Ihre Stromrechnung #{Buzzn::Utils::Chronos.now.prev_year.strftime('%Y')}.

Bei Fragen oder sonstigem Feedback stehen wir Ihnen gerne zur Verfügung.

Vielen Dank, dass Sie People Power unterstützen, die Energiewende von unten.

Energiegeladene Grüße,

Ihr BUZZN Team
)

      document = resource.object.documents.order(:created_at).last

      mail_params = {:from => billing_email_from,
                     :to => email,
                     :subject => subject,
                     :text => text,
                     :bcc => billing_email_bcc,
                     :from_person_id => receiver_person.id,
                     :document_id => document.id}

      reply_to = resource.object.localpool.owner.email

      unless reply_to.nil?
        mail_params[:reply_to] = reply_to
      end

      mail_service.deliver_billing_later(resource.object.id, mail_params)
    end
  end

  def execute_pre_transistion(resource:, params:, actions:, vat:)
    if actions.is_a?(Array)
      actions.select { |a| a[:at] == :pre }.collect { |a| handle_action(resource: resource, params: params, action: a[:action], vat: vat) }
    end
  end

  def execute_post_transistion(resource:, params:, actions:, vat:, **)
    if actions.is_a?(Array)
      actions.select { |a| a[:at] == :post }.collect { |a| handle_action(resource: resource, params: params, action: a[:action], vat: vat) }
    end
  end

  def wrap_up(persist:, **)
    persist
  end

end
