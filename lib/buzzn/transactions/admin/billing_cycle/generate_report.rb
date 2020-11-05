# coding: utf-8

require_relative '../billing_cycle'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class Transactions::Admin::BillingCycle::GenerateReport < Transactions::Base

  add :generate_report_file
  map :wrap_up

  def generate_report_file(resource:, params:)
    workbook = RubyXL::Workbook.new
    sheet = workbook.worksheets[0]
    sheet.sheet_name="Report #{resource.object.last_date.year}"
    header_row = [
      'Vertragsnummer',
      'Mieternummer',
      'Adresszusatz',
      'Name',
      'Beginn',
      'Ende',
      'Bezugsmenge in kWh',
      'Rechnungsbetrag (netto) in €',
      'Rechnungsbetrag (brutto) in €',
      'Guthaben vor Rechnungserstellung (brutto) in €',
      'Restforderung(-)/Guthaben(+) (brutto) in €',
      'Abschläge neu? (brutto) in €',
      'Fällig ab'
    ]
    header_row.each_with_index do |e, idx|
      sheet.add_cell(0, idx, e)
    end

    sheet.change_row_fill(0, 'bfbfbf')

    resource.object.billings.reject { |x| %w(open void).include?(x.status) }.each_with_index do |billing, idx|
      sheet.add_cell(1+idx, 0, billing.contract.full_contract_number)
      sheet.add_cell(1+idx, 1, '')
      sheet.add_cell(1+idx, 2, billing.contract.register_meta.name)
      sheet.add_cell(1+idx, 3, billing.contract.customer.name)

      cell = sheet.add_cell(1+idx, 4, billing.begin_date.strftime('%d.%m.%Y'))
      cell.set_number_format('dd.mm.yy')

      cell = sheet.add_cell(1+idx, 5, billing.last_date.strftime('%d.%m.%Y'))
      cell.set_number_format('dd.mm.yy')

      sheet.add_cell(1+idx, 6, billing.total_consumed_energy_kwh.round(0))
      cell = sheet.add_cell(1+idx, 7, (billing.total_amount_before_taxes.round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(1+idx, 8, (billing.total_amount_after_taxes.round(0) / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(1+idx, 9,  (BigDecimal(billing.balance_before) / 10 / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(1+idx, 10, (BigDecimal(billing.balance_at) / 10 / 100).round(2))
      cell.set_number_format('####.00')
      cell = sheet.add_cell(1+idx, 11, billing.adjusted_payment.nil? ? '-' : BigDecimal(billing.adjusted_payment.price_cents, 4) / 100)
      cell.set_number_format('####.00')
      sheet.add_cell(1+idx, 12, billing.adjusted_payment.nil? ? '-' : billing.adjusted_payment.begin_date.strftime('%d.%m.%Y'))
    end
    workbook.stream
  end

  def wrap_up(generate_report_file:, **)
    generate_report_file
  end

end
