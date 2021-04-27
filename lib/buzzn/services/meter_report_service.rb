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
      'Com'
    ]
    target << header_row.join(';')
    Register::Meta.all.to_a.each do |register_meta|
      if register_meta.register.nil?
      else
        meter = Meter::Base.find(register_meta.register.meter_id)
        group = Group::Localpool.find(meter.group_id)
        target << "\n"
        target << group.name << ';'
        target << register_meta.name << ';'
        target << meter.manufacturer_name << ';'
        target << meter.product_name << ';'
        target << meter.ownership << ';'
        target << meter.build_year << ';'
        target << meter.calibrated_until.nil? ? '' : meter.calibrated_until.strftime('%d.%m.%Y') << ';'
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
        target << meter.comments.map {|c| c.author + ': ' + c.content}.join('|')
      end
    end
    ReportDocument.store(job_id, target.string)
  end
end
