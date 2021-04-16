require_relative '../services'
require_relative '../workers/report_worker'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

require 'net/http'

class Services::ReportService

  def initialize()
    super
    @logger = Buzzn::Logger.new(self)
  end

  def generate_meter_report_async
    Buzzn::Workers::MeterReportWorker.perform_async
  end

  def generate_meter_report(job_id)
    billing_cyle = BillingCycle.find(billing_cycle_id)
    target = StringIO.new
    # Converts the result into a datev readable charset.
    # According to https://apps.datev.de/dnlexka/document/1001008
    # The charset has to be ansii.
    target.set_encoding(Encoding.find('WINDOWS-1252'))
    header_row = [
      'Vertragsnummer',
      'Mieternummer',
      'Adresszusatz',
      'Name',
      'Beginn',
      'Ende',
      'Bezugsmenge in kWh',
      'Betrag netto in €',
      'Betrag USt in €',
      'Betrag brutto in €',
      'Guthaben vor Rechnungserstellung (brutto) in €',
      'Restforderung(-)/Guthaben(+) (brutto) in €',
      'Abschläge neu? (brutto) in €',
      'Fällig ab'
    ]
    target << header_row.join(';')
    billing_cyle.billings.reject { |x| %w(open void).include?(x.status) }.each_with_index do |billing, idx|
      target << "\n"
      target << format('6%i%.3i', billing.contract.contract_number % 100, billing.contract.contract_number_addition) << ';'
      target << '' << ';'
      target << billing.contract.register_meta.name << ';'
      target << billing.contract.customer.name << ';'
      target << billing.begin_date.strftime('%d.%m.%Y') << ';'
      target << Date.new(2020, 6, 30).strftime('%d.%m.%Y') << ';'
      target << billing.consumed_energy_kwh_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) << ';'
      target << (billing.amount_before_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2) << ';'
      target << ((billing.amount_after_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2) - (billing.amount_before_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2)) << ';'
      target << (billing.amount_after_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2) << ';'
      target << '' << ';'
      target << '' << ';'
      target << '' << ';'
      target << ''
      target << "\n"
      target << format('6%i%.3i', billing.contract.contract_number % 100, billing.contract.contract_number_addition) << ';'
      target << '' << ';'
      target << billing.contract.register_meta.name << ';'
      target << billing.contract.customer.name << ';'
      target << Date.new(2020, 7, 1).strftime('%d.%m.%Y') << ';'
      target << billing.last_date.strftime('%d.%m.%Y') << ';'
      target << billing.consumed_energy_kwh_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) << ';'
      target << (billing.amount_before_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2) << ';'
      target << (billing.amount_after_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2) - (billing.amount_before_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2) << ';'
      target << (billing.amount_after_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2) << ';'
      target << (BigDecimal(billing.balance_before) / 10 / 100).round(2) << ';'
      target << (BigDecimal(billing.balance_at) / 10 / 100).round(2) << ';'
      target << (billing.adjusted_payment.nil? ? '-' : BigDecimal(billing.adjusted_payment.price_cents, 4) / 100) << ';'
      target << (billing.adjusted_payment.nil? ? '-' : billing.adjusted_payment.begin_date.strftime('%d.%m.%Y')) 
    end
    ReportDocument.store(job_id, target.string)
  end
end