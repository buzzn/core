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

  def generate_report_async(billing_cycle_id)
    Buzzn::Workers::ReportWorker.perform_async(billing_cycle_id)
  end

  def generate_report(billing_cycle_id, job_id)
    billing_cyle = BillingCycle.find(billing_cycle_id)
    workbook = RubyXL::Workbook.new
    sheet = workbook.worksheets[0]
    sheet.sheet_name="Report #{billing_cyle.last_date.year}"
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
    header_row.each_with_index do |e, idx|
      sheet.add_cell(0, idx, e)
    end

    sheet.change_row_fill(0, 'bfbfbf')
    i = 1
    billing_cyle.billings.reject { |x| %w(open void).include?(x.status) }.each_with_index do |billing, idx|
      sheet.add_cell(i+idx, 0, billing.contract.full_contract_number)
      sheet.add_cell(i+idx, 1, '')
      sheet.add_cell(i+idx, 2, billing.contract.register_meta.name)
      sheet.add_cell(i+idx, 3, billing.contract.customer.name)

      cell = sheet.add_cell(i+idx, 4, billing.begin_date.strftime('%d.%m.%Y'))
      cell.set_number_format('dd.mm.yy')

      cell = sheet.add_cell(i+idx, 5, Date.new(2020, 6, 30).strftime('%d.%m.%Y'))
      cell.set_number_format('dd.mm.yy')

      sheet.add_cell(i+idx, 6, billing.consumed_energy_kwh_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0))
      cell = sheet.add_cell(i+idx, 7, (billing.amount_before_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 8, ((billing.amount_after_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2) - (billing.amount_before_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2)))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 9, (billing.amount_after_taxes_in_date_range(billing.begin_date...Date.new(2020, 6, 30)).round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 10, '')
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 11, '')
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 12, '')
      cell.set_number_format('####.00')
      sheet.add_cell(i+idx, 13, '')

      i = i+1
      sheet.add_cell(i+idx, 0, billing.contract.full_contract_number)
      sheet.add_cell(i+idx, 1, '')
      sheet.add_cell(i+idx, 2, billing.contract.register_meta.name)
      sheet.add_cell(i+idx, 3, billing.contract.customer.name)

      cell = sheet.add_cell(i+idx, 4, Date.new(2020, 7, 1).strftime('%d.%m.%Y'))
      cell.set_number_format('dd.mm.yy')

      cell = sheet.add_cell(i+idx, 5, billing.last_date.strftime('%d.%m.%Y'))
      cell.set_number_format('dd.mm.yy')

      sheet.add_cell(i+idx, 6, billing.consumed_energy_kwh_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0))
      cell = sheet.add_cell(i+idx, 7, (billing.amount_before_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 8, (billing.amount_after_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2) - (billing.amount_before_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 9, (billing.amount_after_taxes_in_date_range(Date.new(2020, 7, 1)...billing.end_date).round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 10, (BigDecimal(billing.balance_before) / 10 / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 11, (BigDecimal(billing.balance_at) / 10 / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(i+idx, 12, billing.adjusted_payment.nil? ? '-' : BigDecimal(billing.adjusted_payment.price_cents, 4) / 100)
      cell.set_number_format('####.00')
      sheet.add_cell(i+idx, 13, billing.adjusted_payment.nil? ? '-' : billing.adjusted_payment.begin_date.strftime('%d.%m.%Y'))

    end
    #workbook.stream
    local_file_path = File.join(File.dirname(File.expand_path(__FILE__)), "../../../db/reports/#{job_id}.xlsx")
    workbook.write(local_file_path)
  end
end
