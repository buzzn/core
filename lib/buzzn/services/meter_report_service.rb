require_relative '../services'
require_relative '../workers/report_worker'

require 'net/http'

class Services::MeterReportService

  def initialize()
    super
    @logger = Buzzn::Logger.new(self)
  end

  def generate_meter_report_async
    Buzzn::Workers::MeterReportWorker.perform_async
  end

  def generate_meter_report(job_id)
    target = StringIO.new
    header_row = [
      'Lokale Energiegruppe',
      'Marktlokation',
      'Isarwatt?',
      'Zählerart',
      'Herstellername',
      'Produktname',
      'Besitzstatus',
      'Baujahr',
      'Geeicht bis',
      'Wandelfaktor',
      'Installationsort',
      'Melo Id',
      'Datenquelle',
      'Energierichtung',
      'Zählernummer',
      'Laufende Nummer',
      'Typ',
      'Turnusintervall',
      'Datenerfassung',
      'Ausleseart',
      'Größe',
      'Zählertyp',
      'Besfestigungsart',
      'Tarifanzahl',
      'Entnahmeebene',
      'Geräteeinbaudatum',
      'Vertragsnummer'
      #Comments field currently not needed
      #'Com'
    ]
    target << header_row.join(';')
    Meter::Base.all.to_a.each do |meter|
      group = Group::Localpool.find(meter.group_id)
      if meter.register_ids.nil? || meter.register_ids == []
      elsif Register::Base.find(meter.register_ids.first).register_meta_id.nil?
      else
        register = Register::Base.find(meter.register_ids.first)
        register_meta = Register::Meta.find(register.register_meta_id)
        readings = register.readings
        if removal_reading?(readings)
        else
          first_reading_date = find_first_reading_date(readings)
          target << "\n"
          target << group.name.gsub(';', ',') << ';'
          target << register_meta.name.gsub(';', ',') << ';'
          target << (group.owner_organization_id == 40 ? 'yes' : 'no') << ';'
          target << register_meta.label << ';'
          target << meter.manufacturer_name << ';'
          target << meter.product_name << ';'
          target << meter.ownership << ';'
          target << meter.build_year << ';'
          target << (meter.calibrated_until.nil? ? '' : meter.calibrated_until.strftime('%d.%m.%Y')) << ';'
          target << meter.converter_constant << ';'
          target << meter.location_description << ';'
          target << meter.metering_location_id << ';'
          target << meter.datasource << ';'
          target << meter.direction_number << ';'
          target << meter.product_serialnumber << ';'
          target << meter.sequence_number << ';'
          target << meter.type << ';'
          target << meter.edifact_cycle_interval << ';'
          target << meter.edifact_data_logging << ';'
          target << meter.edifact_measurement_method << ';'
          target << meter.edifact_meter_size << ';'
          target << meter.edifact_metering_type << ';'
          target << meter.edifact_mounting_method << ';'
          target << meter.edifact_tariff << ';'
          target << meter.edifact_voltage_level << ';'
          target << first_reading_date << ';'
          target << (register.contracts.nil? || register.contracts == [] ? '' : register.contracts.first.contract_number.to_s + '/' + register.contracts.first.contract_number_addition.to_s)
          #Comments field currently not needed
          #target << (meter.comments.map {|c| c.author + ': ' + c.content.gsub(/\n/, ' ')}.join(','))
        end
      end
    end
    ReportDocument.store(job_id, target.string)
  end

  def find_first_reading_date(readings)
    if readings.nil? || readings == []
      'ERROR'
    else
      first_reading = readings.select { |reading| (reading['reason'] == 'IOM' || reading['reason'] == 'COM2' || reading['reason'] == 'COB')}
      if first_reading.length == 1
        first_reading.first['date'].strftime('%d.%m.%Y')
      else
        'ERROR'
      end
    end
  end

  def removal_reading?(readings)
    if readings.nil? || readings == []
      false
    elsif readings.select { |reading| (reading['reason'] == 'ROM' || reading['reason'] == 'COM1')}.length.positive?
      true
    else
      false
    end
  end

end
