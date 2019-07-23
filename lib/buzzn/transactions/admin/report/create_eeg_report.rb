require_relative '../report'
require_relative '../../../schemas/transactions/admin/report/create_eeg_report'

class Transactions::Admin::Report::CreateEegReport < Transactions::Base

  validate :schema
#  authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  add :warnings
  add :date_range
  add :register_metas
  add :calculate_production
  add :calculate_production_pv
  add :calculate_production_chp
  add :calculate_grid_feeding
  add :calculate_consumption
  add :calculate_consumption_common
  add :calculate_production_usage_ratio
  add :calculate_grid_consumption
  add :contracts_with_range
  add :contracts_with_range_and_readings
  add :calculate_grid_consumption_corrected
  add :calculate_grid_feeding_corrected
  add :calculate_grid_feeding_corrected_usage_ratio
  add :calculate_grid_feeding_chp
  add :calculate_grid_feeding_pv
  add :calculate_veeg
  add :calculate_veeg_reduced
  add :count_consumption_points_full
  add :calculate_average_per_meter_full
  add :count_consumption_points_reduced
  add :calculate_average_per_meter_reduced
  add :calculate_consumption_own_production_wh
  add :calculate_consumption_grid_wh
  add :calculate_consumption_prodcution_ratio
  add :count_contracts_third_party
  add :calculate_consumption_third_party_average
  add :calculate_baseprice_per_year_ct
  add :calculate_energyprice_cents_per_kwh_before_taxes
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
                   calculate_production_pv:,
                   calculate_production_chp:,
                   calculate_production_usage_ratio:,
                   calculate_grid_feeding:,
                   calculate_consumption:,
                   calculate_consumption_common:,
                   calculate_grid_consumption:,
                   calculate_grid_consumption_corrected:,
                   calculate_grid_feeding_corrected:,
                   calculate_grid_feeding_chp:,
                   calculate_grid_feeding_pv:,
                   calculate_veeg:,
                   calculate_veeg_reduced:,
                   count_consumption_points_full:,
                   calculate_average_per_meter_full:,
                   count_consumption_points_reduced:,
                   calculate_average_per_meter_reduced:,
                   calculate_consumption_own_production_wh:,
                   calculate_consumption_grid_wh:,
                   calculate_consumption_prodcution_ratio:,
                   count_contracts_third_party:,
                   calculate_consumption_third_party_average:,
                   calculate_baseprice_per_year_ct:,
                   calculate_energyprice_cents_per_kwh_before_taxes:,
                   warnings:,
                   **)
    {
      warnings: warnings,
      production_wh:          calculate_production,
      production_pv_wh:       calculate_production_pv,
      production_chp_wh:      calculate_production_chp,
      production_usage_ratio: calculate_production_usage_ratio,
      grid_feeding_wh:        calculate_grid_feeding,
      consumption_wh:         calculate_consumption,
      consumption_common_wh:  calculate_consumption_common,
      grid_consumption_wh:    calculate_grid_consumption,
      grid_consumption_corrected_wh: calculate_grid_consumption_corrected,
      grid_feeding_corrected_wh: calculate_grid_feeding_corrected,
      grid_feeding_chp_wh: calculate_grid_feeding_chp,
      grid_feeding_pv_wh: calculate_grid_feeding_pv,
      veeg_wh: calculate_veeg,
      veeg_reduced_wh: calculate_veeg_reduced,
      consumption_points_full: count_consumption_points_full,
      consumption_average_per_meter_full: calculate_average_per_meter_full,
      consumption_points_reduced: count_consumption_points_reduced,
      consumption_average_per_meter_reduced: calculate_average_per_meter_reduced,
      consumption_own_production_wh: calculate_consumption_own_production_wh,
      consumption_grid_wh: calculate_consumption_grid_wh,
      consumption_prodcution_ratio: calculate_consumption_prodcution_ratio,
      consumption_third_party_wh: contracts_with_range_and_readings[:third_party_wh],
      contracts_third_party: count_contracts_third_party,
      consumption_third_party_average: calculate_consumption_third_party_average,
      baseprice_per_year_ct: calculate_baseprice_per_year_ct,
      energyprice_cents_per_kwh_before_taxes: calculate_energyprice_cents_per_kwh_before_taxes
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
      calculate_grid_feeding-(calculate_grid_consumption-contracts_with_range_and_readings[:third_party_wh])
    end
  end

  def calculate_grid_feeding(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas, date_range: date_range,
                     label: :grid_feeding, warnings: warnings).round(2).to_f
  end

  def calculate_grid_feeding_pv(calculate_production_pv:,
                                register_metas:, date_range:, warnings:, **)
    calculate_production_pv-calculate_system(register_metas: register_metas,
                                             date_range: date_range,
                                             label: :demarcation_pv,
                                             warnings: warnings).round(2).to_f
  end

  def calculate_grid_feeding_chp(calculate_production_chp:,
                                 register_metas:,
                                 date_range:,
                                 warnings:, **)
    calculate_production_chp-calculate_system(register_metas: register_metas,
                                              date_range: date_range,
                                              label: :demarcation_chp,
                                              warnings: warnings).round(2).to_f
  end

  def calculate_grid_feeding_corrected_usage_ratio(calculate_consumption_common:,
                                                   calculate_production:,
                                                   **)
    "asdf"
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
        if register.installed_at.nil?
          warnings.push(
            reason: 'skipped register',
            register_id: register.id,
            meter_id: register.meter.id
          )
          puts "skipped register #{register.id}, not installed"
          next
        end
        if register.installed_at.date > end_date
          puts "skipped register #{register.id}"
          next
        end
        if !register.decomissioned_at.nil? && register.decomissioned_at.date <= begin_date
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

  def calculate_production_pv(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas,
                     date_range: date_range,
                     label: :production_pv,
                     warnings: warnings).round(2).to_f
  end

  def calculate_production_chp(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas,
                     date_range: date_range,
                     label: :production_chp,
                     warnings: warnings).round(2).to_f
  end

  def calculate_production_usage_ratio(calculate_consumption_common:,
                                       calculate_production:,
                                       date_range:, warnings:, **)
    if calculate_production.zero?
      return 0
    end

    0 + calculate_consumption_common * 100 / calculate_production
  end

  # Returns the overall electricity consumption.
  #
  # @param register_metas [Array<Meta>] the metas to read from.
  # @param date_range [date_range]  Time period to take into account.
  # @param warnings [Array] Warnings occourred.
  def calculate_consumption(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas,
                     date_range: date_range,
                     label: :consumption,
                     warnings: warnings).round(2).to_f
  end

  # Returns the group's electricity consumption.
  #
  # @param register_metas [Array<Meta>] the metas to read from.
  # @param date_range [date_range]  Time period to take into account.
  # @param warnings [Array] Warnings occourred.
  def calculate_consumption_common(register_metas:, date_range:, warnings:, **)
    calculate_system(register_metas: register_metas,
                     date_range: date_range,
                     label: :consumption_common,
                     warnings: warnings).round(2).to_f
  end

  # Counts the consumtion points of all contracts with full taxation.
  #
  # @param contracts_with_range [Array<Hash>] All the contracts to inspect.
  # @return [number] The number of consumption points.
  def count_consumption_points_full(contracts_with_range:, **)
    contracts_with_range.map {|c| c[:contract]}
                        .select {|c| c.renewable_energy_law_taxation == 'full'}
                        .map(&:register_meta)
                        .flat_map(&:registers)
                        .count {|r| r.kind == :consumption}
  end

  # @param count_consumption_points_reduced [number] Number of non tax reduced consumption points.
  # @param calculate_veeg_reduced [number] Used amount of non tax reduced electricity
  # @return [number] the average consumption per meter for all non tax reduced contracts.
  def calculate_average_per_meter_full(count_consumption_points_full:,
                                       calculate_veeg:,
                                       **)
    calculate_veeg / count_consumption_points_full
  end

  # Counts the consumtion points of all contracts with reduced taxation.
  #
  # @param contracts_with_range [Array<Hash>] All the contracts to inspect.
  # @return [number] The number of consumption points.
  def count_consumption_points_reduced(contracts_with_range:, **)
    contracts_with_range.map {|c| c[:contract]}
                        .select {|c| c.renewable_energy_law_taxation == 'reduced'}
                        .map(&:register_meta)
                        .flat_map(&:registers)
                        .count {|r| r.kind == :consumption}
  end

  # @param count_consumption_points_reduced [number] Number of tax reduced consumption points.
  # @param calculate_veeg_reduced [number] Used amount of tax reduced electricity
  # @return [number] the average consumption per meter for all reduced taxed contracts.
  def calculate_average_per_meter_reduced(
        count_consumption_points_reduced:,
        calculate_veeg_reduced:,
        **
  )
    if count_consumption_points_reduced.zero?
      return 0
    end
    calculate_veeg_reduced / count_consumption_points_reduced
  end

  # @param calculate_grid_feeding [number] Amount of grid fed electricity.
  # @param calculate_production [number] Amount of produced electricity.
  # @return [number] The calculated consumption of the own produced power.
  def calculate_consumption_own_production_wh(calculate_grid_feeding:, calculate_production:, **)
    calculate_production - calculate_grid_feeding
  end

  # @param [number] calculate_consumption
  # @return [number] The calculated consumption of grid power.
  def calculate_consumption_grid_wh(calculate_consumption:,
                                    calculate_consumption_own_production_wh:,
                                    **
  )
    calculate_consumption - calculate_consumption_own_production_wh
  end

  # @param calculate_consumption [number] Amount of electricity consumption.
  # @param calculate_grid_consumption [number] Amount of electricity consumpted through grid.
  # @return [number] the ratio of electricity produced and consumpted in percent.
  def  calculate_consumption_prodcution_ratio(calculate_consumption:,
                                              calculate_grid_consumption:,
                                              **)
    (1.0 - calculate_grid_consumption / calculate_consumption) * 100
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

  # @param [Array<Contract>] All contracts to take into account.
  # @returns [number] The number of all third party contracts. TODO docu: what is a third party contract?
  def count_contracts_third_party(contracts_with_range:, **)
    contracts_with_range.select {|r| r[:contract].is_a? Contract::LocalpoolThirdParty}.count
  end

  # @param [number] count_contracts_third_party Number of third party contracts.
  # @param [number] contracts_with_range_and_readings Accumulated consumption of
  #                 third party contracts.
  # @return [number] Average consumption of third party contract.
  def calculate_consumption_third_party_average(count_contracts_third_party:,
                                                contracts_with_range_and_readings:,
                                                **)
    if count_contracts_third_party.zero?
      return 0;
    end

    contracts_with_range_and_readings[:third_party_wh] / count_contracts_third_party
  end

  # @param  [Array] The contracts in taken into account.
  #
  # @return Accumulated price in cents.
  def calculate_baseprice_per_year_ct(contracts_with_range:, **)
    baseprices = contracts_with_range.map {|c| c[:contract]}
                                     .flat_map(&:tariffs)
                                     .map(&:baseprice_cents_per_month_before_taxes).uniq

    if baseprices.count != 1
      raise 'Platform can not yet handle groups with more or less than one baseprice.'
    end

    baseprices.first * 12
  end

  # Das muss alle tarife zeigen und alle mitglieder die den haben
  def calculate_energyprice_cents_per_kwh_before_taxes(contracts_with_range:, **)
    energyprices = contracts_with_range.map {|c| c[:contract]}
                                       .flat_map(&:tariffs)
                                       .map(&:energyprice_cents_per_kwh_before_taxes).uniq

    if energyprices.count !=1
      raise 'Platform yet only handle groups which have exactly one tarif.'
    end

    energyprices.first
  end

  def contracts_with_range_and_readings(contracts_with_range:, **)
    errors = []
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
        if register_end_date <= register_begin_date || register_begin_date >= register_end_date
          next
        end
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
      raise Buzzn::ValidationError.new(contracts: errors)
    end
    ret[:third_party_wh] = ret[:third_party_wh].round(2).to_f
    ret[:reduced_wh] = ret[:reduced_wh].round(2).to_f
    ret[:normal_wh] = ret[:normal_wh].round(2).to_f
    ret
  end

end
