require_relative '../report'
require_relative '../../../schemas/transactions/admin/report/create_eeg_report'

class Transactions::Admin::Report::CreateEegReport < Transactions::Base

  validate :schema
  authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  add :warnings
  add :date_range
  add :register_metas
  add :calculate_production
  add :calculate_grid_feeding
  add :calculate_grid_consumption
  add :contracts_with_range
  add :contracts_with_range_and_readings
  add :calculate_grid_consumption_corrected
  add :calculate_grid_feeding_corrected
  add :calculate_veeg
  add :calculate_veeg_reduced
  map :build_result

  include Import['services.reading_service']

  def schema
    Schemas::Transactions::Admin::Report::CreateEegReport
  end

  def allowed_roles(permission_context:)
    permission_context.reports.eeg.create
  end

  def warnings(**)
    []
  end

  def build_result(contracts_with_range_and_readings:,
                   calculate_production:,
                   calculate_grid_feeding:,
                   calculate_grid_consumption:,
                   calculate_grid_consumption_corrected:,
                   calculate_grid_feeding_corrected:,
                   calculate_veeg:,
                   calculate_veeg_reduced:,
                   warnings:,
                   **)
    {
      warnings: warnings,
      production_wh:       calculate_production,
      grid_feeding_wh:     calculate_grid_feeding,
      grid_consumption_wh: calculate_grid_consumption,
      grid_consumption_corrected_wh: calculate_grid_consumption_corrected,
      grid_feeding_corrected_wh: calculate_grid_feeding_corrected,
      veeg_wh: calculate_veeg,
      veeg_reduced_wh: calculate_veeg_reduced,
    }.merge(contracts_with_range_and_readings)
  end

  def calculate_veeg_reduced(contracts_with_range_and_readings:, calculate_grid_consumption_corrected:, **)
    contracts_with_range_and_readings[:reduced_wh] - calculate_grid_consumption_corrected * (contracts_with_range_and_readings[:reduced_wh] / (contracts_with_range_and_readings[:normal_wh]+contracts_with_range_and_readings[:reduced_wh]))
  end

  def calculate_veeg(contracts_with_range_and_readings:, calculate_grid_consumption_corrected:, **)
    contracts_with_range_and_readings[:normal_wh] - calculate_grid_consumption_corrected * (contracts_with_range_and_readings[:normal_wh]/(contracts_with_range_and_readings[:normal_wh] + contracts_with_range_and_readings[:reduced_wh]))
  end

  # grid consumption without total consumption of third parties
  def calculate_grid_consumption_corrected(contracts_with_range_and_readings:, calculate_grid_consumption:, **)
    [calculate_grid_consumption-contracts_with_range_and_readings[:third_party_wh], 0].max
  end

  def calculate_grid_feeding_corrected(contracts_with_range_and_readings:, calculate_grid_feeding:, calculate_grid_consumption:, **)
    if (calculate_grid_consumption-contracts_with_range_and_readings[:third_party_wh]).positive?
      calculate_grid_feeding
    else
      calculate_grid_feeding-(calculate_grid_consumption+contracts_with_range_and_readings[:third_party_wh])
    end
  end

  def date_range(params:, resource:, **)
    if params[:end_date] <= params[:begin_date]
      raise Buzzn::ValidationError.new(begin_date: ['must be before end_date'])
    end
    params.delete(:begin_date)...params.delete(:end_date)
  end

  def register_metas(resource:, **)
    resource.object.register_metas_by_registers.uniq # uniq is critically important here!
  end

  def calculate_system(register_metas:, date_range:, label:, warnings:, **)
    sum = 0
    metas = register_metas.select { |x| x.send(label.to_s + '?') }
    begin_date = date_range.first
    end_date   = date_range.last
    errors = []
    # figure out ranges
    metas.each do |meta|
      meta.registers.each do |register|
        if (register.installed_at.nil? || register.installed_at.date > date_range.last) && (register.decomissioned_at.nil? || register.decomissioned_at.date < date_range.first)
          warnings.push(
            reason: 'skipped register',
            register_id: register.id,
            meter_id: register.meter.id
          )
          puts "skipped register #{register.id}"
          next
        end
        register_begin_date = [begin_date, register.installed_at&.date || begin_date].max
        register_end_date   = [end_date, register.decomissioned_at&.date || end_date].min
        begin_reading = begin
                          reading_service.get(register, register_begin_date, :precision => 2.days).to_a.max_by(&:value)
                        rescue Buzzn::DataSourceError
                          nil
                        end
        end_reading = begin
                        reading_service.get(register, register_end_date, :precision => 2.days).to_a.max_by(&:value)
                      rescue Buzzn::DataSourceError
                        nil
                      end
        if !begin_reading.nil? && !end_reading.nil?
          sum += BigDecimal(end_reading.value) - BigDecimal(begin_reading.value)
        else
          if begin_reading.nil?
            errors.push(
              errors: [
                {
                  reason: 'begin_reading missing',
                  date: register_begin_date,
                  register_id: register.id,
                  meter_id: register.meter.id,
                  register_meta_id: meta.id
                }
              ]
            )
          end
          if end_reading.nil?
            errors.push(
              errors: [
                {
                  reason: 'end_reading missing',
                  date: register_end_date,
                  register_id: register.id,
                  meter_id: register.meter.id,
                  register_meta_id: meta.id
                }
              ]
            )
          end
        end
      end
    end
    unless errors.empty?
      raise Buzzn::ValidationError.new(errors)
    end
    sum
  end

  def calculate_production(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas, date_range: date_range, label: :production, warnings: warnings).round(2).to_f
  end

  def calculate_grid_feeding(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas, date_range: date_range, label: :grid_feeding, warnings: warnings).round(2).to_f
  end

  def calculate_grid_consumption(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas, date_range: date_range, label: :grid_consumption, warnings: warnings).round(2).to_f
  end

  def contracts_with_range(params:, resource:, register_metas:, date_range:, **)
    ret = []
    register_metas.each do |register_meta|
      register_meta.contracts.each do |contract|
        if contract.begin_date >= date_range.last || (!contract.end_date.nil? && contract.end_date <= date_range.first)
          next
        end
        report_date_range = contract.minmax_date_range(date_range)
        # check if valid
        ret.push(begin_date: report_date_range.first,
                 end_date: report_date_range.last,
                 contract: contract)
      end
    end
    ret
  end

  def validate_contracts(contracts_with_range:, **)
    contracts_with_range.each do |attrs|
      contract = attrs[:contract]
      if contract.register_meta.registers.to_a.keep_if { |register| register.installed_at.date < date_range.last && (register.decomissioned_at.nil? || register.decomissioned_at.date > date_range.first) }.empty?
        raise Buzzn::ValidationError.new(:contract => {
                                           :id => contract.id,
                                           :register_meta => ['no register installed in date range']
                                         })
      end
    end
  end

  def contracts_with_range_and_readings(contracts_with_range:, **)
    errors = {}
    ret = {
      third_party_wh: 0,
      reduced_wh: 0,
      normal_wh: 0,
    }
    contracts_with_range.map do |attrs|
      contract = attrs[:contract]
      sum = 0
      contract.register_meta.registers.each do |register|
        begin_date = attrs[:begin_date]
        end_date = attrs[:end_date]
        register_begin_date = [begin_date, register.installed_at&.date || begin_date].max
        register_end_date   = [end_date,   register.decomissioned_at&.date || end_date].min
        begin_reading = begin
                          reading_service.get(register, register_begin_date, :precision => 2.days).to_a.max_by(&:value)
                        rescue Buzzn::DataSourceError
                          errors.push(
                            contract_id: contract.id,
                            errors: [
                              {
                                reason: 'begin_reading missing',
                                date: register_begin_date,
                                register_id: register.id
                              }
                            ]
                          )
                          nil
                        end
        end_reading = begin
                          reading_service.get(register, register_end_date, :precision => 2.days).to_a.max_by(&:value)
                        rescue Buzzn::DataSourceError
                          errors.push(
                            contract_id: contract.id,
                            errors: [
                              {
                                reason: 'begin_reading missing',
                                date: register_begin_date,
                                register_id: register.id
                              }
                            ]
                          )
                          nil
                        end
        if !begin_reading.nil? && !end_reading.nil?
          sum += BigDecimal(end_reading.value) - BigDecimal(begin_reading.value)
        end
      end
      attrs.tap do |h|
        if contract.is_a? Contract::LocalpoolThirdParty
          ret[:third_party_wh] += sum
        elsif contract.renewable_energy_law_taxation == 'reduced'
          # reduced
          ret[:reduced_wh] += sum
        else
          # normal
          ret[:normal_wh] += sum
        end
      end
    end
    unless errors.empty?
      raise Buzzn::ValidationError.new(errors)
    end
    ret[:third_party_wh] = ret[:third_party_wh].round(2).to_f
    ret[:reduced_wh] = ret[:reduced_wh].round(2).to_f
    ret[:normal_wh] = ret[:normal_wh].round(2).to_f
    ret
  end

end
