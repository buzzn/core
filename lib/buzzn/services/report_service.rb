require_relative '../services'
require_relative '../workers/report_worker'
require_relative '../workers/historical_export_worker'
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
      payment = billing.adjusted_payment || billing.contract.current_payment
      billing_ends_contract = billing.contract.end_date.nil? ? false : billing.end_date == billing.contract.end_date
      target << "\n"
      target << format('6%.2i%.3i', billing.contract.contract_number % 100, billing.contract.contract_number_addition) << ';'
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
      target << format('6%.2i%.3i', billing.contract.contract_number % 100, billing.contract.contract_number_addition) << ';'
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
      target << (billing_ends_contract ? '-' : BigDecimal(payment.price_cents, 4) / 100) << ';'
      target << (billing_ends_contract ? '-' : payment.begin_date.strftime('%d.%m.%Y'))
    end
    ReportDocument.store(job_id, target.string)
  end

  def generate_export_async(localpool_id)
    Buzzn::Workers::HistoricalExportWorker.perform_async(localpool_id)
  end

  def labels
    {
      'GRID_FEEDING' => 'ÜGZ Einspeisung',
      'GRID_CONSUMPTION'=> 'ÜGZ Bezug',
      'PRODUCTION_WATER'=> 'Produktion',
      'PRODUCTION_PV'=> 'Produktion'
    }
  end

  def generate_historical_export(localpool_id, job_id)
    localpool = Group::Localpool.find(localpool_id)
    active_meters = localpool.meters.reject{|x| x.decomissioned?}
    date_pmr_2019 = DateTime.parse("31-12-2019")
    date_pmr_2020 = DateTime.parse("31-12-2020")
    target = StringIO.new
    target.set_encoding(Encoding.find('UTF-8'))
    header_row1 = [
      localpool.name,
      '',
      '',
      'Datum der Ablesung',
      '',
      "31.12.#{Date.today.year}"
    ]
    target << header_row1.join(';')
    target << "\n"
    header_row2 = [
      'Vertragsnummer',
      'MSB-id',
      'Mieternummer',
      'Zählernummer',
      'Installationsort',
      'Zusatz',
      'Vorname',
      'Nachname',
      'Adresszusatz',
      'Zählerstand',
      'bezahlte Abschläge in €',
      'Rechnungsnummer',
      'Zählertyp',
      'Zählereinbau',
      'Zählerstand Einbau',
      'Zählerstand Turnusabrechnung 2019',
      'Ablesedatum Turnusabrechnung 2019',
      'Zählerstand Turnusabrechnung 2020',
      'Ablesedatum Turnusabrechnung 2020'
    ]
    target << header_row2.join(';')

    active_meters.each do |meter|
      meter.registers.select {|rm| rm.contracts.any? {|c| c.status == 'active'}}.each do |register|
        register_meta_id = register.register_meta_id
        register_meta = Register::Meta.find(register_meta_id)
        paid_requested = true
        billnumber_requested = true

        # We filtered those which do have a valid contract before, so there must be exactly one!
        contract = register_meta.contracts.select {|c| c.status == 'active'}[0]
        if contract.is_a?(Contract::LocalpoolPowerTaker)
          contract_additional_info = 'Bezug'
        elsif contract.is_a?(Contract::LocalpoolThirdParty)
          contract_additional_info = 'Drittbeliefert'
          paid_requested = false
          billnumber_requested = false
        end

        unless contract.customer.nil?
          if contract.customer.is_a? Person
            first_name = contract.customer.first_name
            last_name = contract.customer.last_name
          else
            last_name = contract.customer.name
          end
        end

        readings = register.readings

        target << "\n"
        target << contract.full_contract_number << ';'
        target << meter.sequence_number << ';'
        target << contract.third_party_renter_number << ';'
        target << meter.product_serialnumber << ';'
        target << meter.location_description << ';'
        target << contract_additional_info << ';'
        target << first_name << ';'
        target << last_name << ';'
        target << register_meta.name << ';'
        target << '' << ';'
        target << (paid_requested ? '' : 'X') << ';'
        target << (billnumber_requested ? '' : 'X') << ';'
        target << (meter.edifact_measurement_method.nil? ? '' : meter.edifact_measurement_method) << ';' # Zaehlertyp
        target << (find_first_reading_date(readings).nil? ? '' : find_first_reading_date(readings)) << ';'
        target << (find_first_reading_value(readings).nil? ? '' : find_first_reading_value(readings)) << ';'
        target << (find_periodic_reading(readings, date_pmr_2019).nil? ? '' : find_periodic_reading(readings, date_pmr_2019).value / 1000) << ';'
        target << (find_periodic_reading(readings, date_pmr_2019).nil? ? '' : find_periodic_reading(readings, date_pmr_2019).date.strftime('%d.%m.%Y')) << ';'
        target << (find_periodic_reading(readings, date_pmr_2020).nil? ? '' : find_periodic_reading(readings, date_pmr_2020).value/ 1000) << ';'
        target << (find_periodic_reading(readings, date_pmr_2020).nil? ? '' : find_periodic_reading(readings, date_pmr_2020).date.strftime('%d.%m.%Y')) << ';'
      end
    end

    active_meters.reject {|m| m.is_a?(Meter::Virtual)}
              .reject {|m| m.registers.all? {|register| register.contracts.any? {|c| c.status == 'active'}}}
              .reject {|m| m.registers.all? {|register| register.contracts.to_a.empty?}}
              .each do |meter|
      meter.registers.each do |register|
        if register.register_meta_id.nil?
          next
        else
          register_meta = Register::Meta.find(register.register_meta_id)
        end

        readings = register.readings

        target << "\n"
        target << '' << ';'
        target << meter.sequence_number << ';'
        target << '' << ';'
        target << meter.product_serialnumber << ';'
        target << meter.location_description << ';'
        target << 'Leerstand' << ';'
        target << '' << ';'
        target << '' << ';'
        target << register_meta.name << ';'
        target << '' << ';'
        target << 'X' << ';'
        target << '' << ';'
        target << (meter.edifact_measurement_method.nil? ? '' : meter.edifact_measurement_method) << ';' # Zaehlertyp
        target << (find_first_reading_date(readings).nil? ? '' : find_first_reading_date(readings)) << ';'
        target << (find_first_reading_value(readings).nil? ? '' : find_first_reading_value(readings)) << ';'
        target << (find_periodic_reading(readings, date_pmr_2019).nil? ? '' : find_periodic_reading(readings, date_pmr_2019).value/ 1000) << ';'
        target << (find_periodic_reading(readings, date_pmr_2019).nil? ? '' : find_periodic_reading(readings, date_pmr_2019).date.strftime('%d.%m.%Y')) << ';'
        target << (find_periodic_reading(readings, date_pmr_2020).nil? ? '' : find_periodic_reading(readings, date_pmr_2020).value/ 1000) << ';'
        target << (find_periodic_reading(readings, date_pmr_2020).nil? ? '' : find_periodic_reading(readings, date_pmr_2020).date.strftime('%d.%m.%Y')) << ';'
      end
    end

    active_meters.reject {|m| m.is_a?(Meter::Virtual)}
              .select {|m| m.registers.all? {|register| register.contracts.to_a.empty?}}
              .each do |meter|
      meter.registers.each do |register|
        if register.register_meta_id.nil?
          next
        else
          register_meta = Register::Meta.find(register.register_meta_id)
        end

        readings = register.readings

        target << "\n"
        target << '' << ';'
        target << meter.sequence_number << ';'
        target << '' << ';'
        target << meter.product_serialnumber << ';'
        target << meter.location_description << ';'
        target << labels[register_meta.label.upcase] << ';'
        target << '' << ';'
        target << '' << ';'
        target << register_meta.name << ';'
        target << '' << ';'
        target << 'X' << ';'
        target << ''<< ';'
        target << (meter.edifact_measurement_method.nil? ? '' : meter.edifact_measurement_method) << ';' # Zaehlertyp
        target << (find_first_reading_date(readings).nil? ? '' : find_first_reading_date(readings)) << ';'
        target << (find_first_reading_value(readings).nil? ? '' : find_first_reading_value(readings)) << ';'
        target << (find_periodic_reading(readings, date_pmr_2019).nil? ? '' : find_periodic_reading(readings, date_pmr_2019).value/ 1000) << ';'
        target << (find_periodic_reading(readings, date_pmr_2019).nil? ? '' : find_periodic_reading(readings, date_pmr_2019).date.strftime('%d.%m.%Y')) << ';'
        target << (find_periodic_reading(readings, date_pmr_2020).nil? ? '' : find_periodic_reading(readings, date_pmr_2020).value/ 1000) << ';'
        target << (find_periodic_reading(readings, date_pmr_2020).nil? ? '' : find_periodic_reading(readings, date_pmr_2020).date.strftime('%d.%m.%Y')) << ';'
      end
    end
    ReportDocument.store(job_id, target.string)
  end

end

def find_first_reading_date(readings)
  unless readings.nil? || readings == []
    first_readings = readings.select { |reading| (reading['reason'] == 'IOM' || reading['reason'] == 'COM2' || reading['reason'] == 'COB')}
    if first_readings.length == 1
      first_readings.first['date'].strftime('%d.%m.%Y')
    else
      'Es existiert mehr als eine Ablesung, die das Merkmal Zählereinbau trägt'
    end
  end
end

def find_first_reading_value(readings)
  unless readings.nil? || readings == []
    first_readings = readings.select { |reading| (reading['reason'] == 'IOM' || reading['reason'] == 'COM2' || reading['reason'] == 'COB')}
    if first_readings.length == 1
      first_readings.first.raw_value / 1000
    end
  end
end

def find_periodic_reading(readings, date)
  unless readings.nil? || readings == []
    periodic_readings = readings.select { |reading| (reading['reason'] == 'PMR' && reading['date'] == date)}
    if periodic_readings.length == 1
      periodic_readings.first
    end
  end
end
