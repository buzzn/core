require_relative '../services'
#require_relative '../workers/report_worker'

require 'net/http'

class Services::PowertakerReportService

  def initialize()
    super
    @logger = Buzzn::Logger.new(self)
  end

  def generate_powertaker_report_async
    Buzzn::Workers::PowertakerReportWorker.perform_async
  end

  def generate_powertaker_report(job_id)
    target = StringIO.new
    header_row = [
      'Organisation?',
      'Name',
      'Nachname',
      'Titel',
      'Adresse',
      'Telefonnummer',
      'Mailadresse',
      'Lokale Energiegruppe',
      'Kontoinhaber',
      'IBAN',
      'BIC',
      'Bank',
      'Bezugsstelle',
      'Vertragsnummer',
      'Datum der Unterzeichnung',
      'Startdatum',
      'Kündigungsdatum',
      'Endtermin',
      'Zahlung in €'
    ]
    target << header_row.join(';')
    Contract::Base.all.to_a.each do |contract|
      customer = contract.contact
      target << "\n"
      target << ((contract.customer.is_a? Organization::Base) ? contract.customer.name : '-') << ';'
      if customer.nil?
        target << '' << ';'
        target << '' << ';'
        target << '' << ';'
        target << '' << ';'
        target << '' << ';'
        target << '' << ';'
      else
        target << customer.first_name << ';'
        target << customer.last_name << ';'
        target << (customer.title.nil? ? '' : customer.title) << ';'
        target << (customer.address.nil? ? '' : (customer.address.street + "," + customer.address.zip + customer.address.city)) << ';'
        target << (customer.phone.nil? ? '' : customer.phone) << ';'
        target << (customer.email.nil? ? '' : customer.email) << ';'
      end
      target << contract.localpool.name << ';'
      target << (contract.customer_bank_account.nil? ? '' : contract.customer_bank_account.holder) << ';'
      target << (contract.customer_bank_account.nil? ? '' : contract.customer_bank_account.iban) << ';'
      target << (contract.customer_bank_account.nil? ? '' : contract.customer_bank_account.bic) << ';'
      target << (contract.customer_bank_account.nil? ? '' : contract.customer_bank_account.bank_name) << ';'
      target << (contract.register_meta.nil? ? '' : contract.register_meta.name) << ';'
      target << "#{contract.contract_number}/#{contract.contract_number_addition}" << ';'
      target << (contract.signing_date.nil? ? '' : contract.signing_date.strftime('%d.%m.%Y')) << ';'
      target << (contract.begin_date.nil? ? '' : contract.begin_date.strftime('%d.%m.%Y')) << ';'
      target << (contract.termination_date.nil? ? '' : contract.termination_date.strftime('%d.%m.%Y')) << ';'
      target << (contract.end_date.nil? ? '' : contract.end_date.strftime('%d.%m.%Y')) << ';'
      target << (contract.payments.nil? || contract.payments == [] ? '' : (contract.payments.order(:begin_date).last.price_cents.to_f / 100).to_s.gsub('.', ','))
    end
    ReportDocument.store(job_id, target.string)
  end

end
