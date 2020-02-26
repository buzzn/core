require_relative '../report'
require('time')

# Holds all the data used by the reports.
class Transactions::Admin::Report::ReportData < Transactions::Base

  # authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  add :warnings
  add :date_range
  add :register_metas
  add :contracts_with_range
  add :contracts_with_range_and_readings
  add :production
  add :production_pv
  add :production_chp
  add :grid_feeding
  add :consumption
  add :consumption_common
  add :production_usage_ratio
  add :grid_consumption
  add :grid_consumption_corrected
  add :grid_feeding_corrected
  add :grid_feeding_corrected_usage_ratio
  add :grid_feeding_chp
  add :grid_feeding_pv
  add :veeg
  add :veeg_reduced
  add :total_consumption_points_full
  add :consumption_average_per_meter_full
  add :total_consumption_points_reduced
  add :consumption_average_per_meter_reduced
  add :consumption_own_production_wh
  add :consumption_grid_wh
  add :consumption_prodcution_ratio
  add :consumption_third_party
  add :total_contracts_third_party
  add :consumption_third_party_average
  add :baseprice_per_year_ct
  add :energyprice_cents_per_kwh_before_taxes

  include Import['services.reading_service']

  def allowed_roles(permission_context:)
    permission_context.reports.eeg.create
  end

  def warnings(**)
    []
  end

  def veeg_reduced(contracts_with_range_and_readings:, grid_consumption_corrected:, **)
    contracts_with_range_and_readings[:reduced_wh] - grid_consumption_corrected * (contracts_with_range_and_readings[:reduced_wh] / (contracts_with_range_and_readings[:normal_wh]+contracts_with_range_and_readings[:reduced_wh]))
  end

  def veeg(contracts_with_range_and_readings:, grid_consumption_corrected:, **)
    contracts_with_range_and_readings[:normal_wh] - grid_consumption_corrected * (contracts_with_range_and_readings[:normal_wh]/(contracts_with_range_and_readings[:normal_wh] + contracts_with_range_and_readings[:reduced_wh]))
  end

  # grid consumption without total consumption of third parties
  def grid_consumption_corrected(contracts_with_range_and_readings:, grid_consumption:, **)
    [grid_consumption-contracts_with_range_and_readings[:third_party_wh], 0].max
  end

  def grid_feeding_corrected(contracts_with_range_and_readings:, grid_feeding:, grid_consumption:, **)
    if (grid_consumption-contracts_with_range_and_readings[:third_party_wh]).positive?
      grid_feeding
    else
      grid_feeding-(grid_consumption-contracts_with_range_and_readings[:third_party_wh])
    end
  end

  def grid_feeding(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas, date_range: date_range,
           label: :grid_feeding, warnings: warnings).round(2).to_f
  end

  def grid_feeding_pv(production_pv:,
                      register_metas:, date_range:, warnings:, **)
    production_pv-system(register_metas: register_metas,
                         date_range: date_range,
                         label: :demarcation_pv,
                         warnings: warnings).round(2).to_f
  end

  def grid_feeding_chp(production_chp:,
                       register_metas:,
                       date_range:,
                       warnings:, **)
    production_chp-system(register_metas: register_metas,
                          date_range: date_range,
                          label: :demarcation_chp,
                          warnings: warnings).round(2).to_f
  end

  def grid_feeding_corrected_usage_ratio(consumption_common:,
                                         production:,
                                         **)
    'grid_feeding_corrected_usage_ratio'
  end


  def date_range(params:, **)
    begin_date = Time.parse(params['begin_date'])
    end_date = Time.parse(params['last_date'])
    if end_date <= begin_date
      raise Buzzn::ValidationError.new(begin_date: ['must be before end_date'])
    end
    begin_date...end_date
  end

  def register_metas(resource:, **)
    resource.object.register_metas_by_registers.uniq # uniq is critically important here!
  end

  def system(register_metas:, date_range:, label:, warnings:, **)
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
            reason: "skipped register #{register.id}, no installation date set or not installed",
            label: register.meta.label,
            register_id: register.id,
            meter_id: register.meter.id,
            product_serialnumber: register.meter.product_serialnumber
          )
          next
        end
        if register.installed_at.date > end_date
          warnings.push(
            reason: "skipped register #{register.id}, because it was installed after reading range #{end_date}",
            register_id: register.id,
            meter_id: register.meter.id,
            product_serialnumber: register.meter.product_serialnumber
          )
          next
        end
        if !register.decomissioned_at.nil? && register.decomissioned_at.date <= begin_date
          warnings.push(
            reason: "skipped register #{register.id}, because it was decomissioned before reading range #{begin_date}",
            register_id: register.id,
            meter_id: register.meter.id,
            product_serialnumber: register.meter.product_serialnumber
          )
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
                  serialnumber: register.meter.product_serialnumber,
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
                  serialnumber: register.meter.product_serialnumber,
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

  def production(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas, date_range: date_range, label: :production, warnings: warnings).round(2).to_f
  end

  def production_pv(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas,
           date_range: date_range,
           label: :production_pv,
           warnings: warnings).round(2).to_f
  end

  def production_chp(register_metas:, date_range:, warnings:, **)
    result = system(register_metas: register_metas,
           date_range: date_range,
           label: :production_chp,
           warnings: warnings).round(2).to_f
    result
  end

  def production_water(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas,
           date_range: date_range,
           label: :production_water,
           warnings: warnings).round(2).to_f
  end

  def production_wind(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas,
           date_range: date_range,
           label: :production_wind,
           warnings: warnings).round(2).to_f
  end

  def production_usage_ratio(consumption:,
                             production:,
                             date_range:, warnings:, **)
    if production.zero?
      return 0
    end
    consumption / production * 100

  end

  # Returns the overall electricity consumption.
  #
  # @param register_metas [Array<Meta>] the metas to read from.
  # @param date_range [date_range]  Time period to take into account.
  # @param warnings [Array] Warnings occourred.
  def consumption(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas,
           date_range: date_range,
           label: :consumption,
           warnings: warnings).round(2).to_f
  end

  # Returns the group's electricity consumption of common power consuming
  # devices such as light in the hallway.
  #
  # @param register_metas [Array<Meta>] the metas to read from.
  # @param date_range [date_range]  Time period to take into account.
  # @param warnings [Array] Warnings occourred.
  def consumption_common(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas,
           date_range: date_range,
           label: :consumption_common,
           warnings: warnings).round(2).to_f
  end

  # Counts the consumtion points of all contracts with full taxation.
  #
  # @param contracts_with_range [Array<Hash>] All the contracts to inspect.
  # @return [number] The number of consumption points.
  def total_consumption_points_full(contracts_with_range:, **)
    contracts_with_range.map {|c| c[:contract]}
                        .select {|c| c.renewable_energy_law_taxation == 'full'}
                        .map(&:register_meta)
                        .flat_map(&:registers)
                        .count {|r| r.kind == :consumption}
  end

  # @param total_consumption_points_reduced [number] Number of non tax reduced consumption points.
  # @param veeg_reduced [number] Used amount of non tax reduced electricity
  # @return [number] the average consumption per meter for all non tax reduced contracts.
  def consumption_average_per_meter_full(total_consumption_points_full:,
                             veeg:,
                             **)
    veeg / total_consumption_points_full
  end

  # Counts the consumtion points of all contracts with reduced taxation.
  #
  # @param contracts_with_range [Array<Hash>] All the contracts to inspect.
  # @return [number] The number of consumption points.
  def total_consumption_points_reduced(contracts_with_range:, **)
    contracts_with_range.map {|c| c[:contract]}
                        .select {|c| c.renewable_energy_law_taxation == 'reduced'}
                        .map(&:register_meta)
                        .flat_map(&:registers)
                        .count {|r| r.kind == :consumption}
  end

  # @param total_consumption_points_reduced [number] Number of tax reduced consumption points.
  # @param veeg_reduced [number] Used amount of tax reduced electricity
  # @return [number] the average consumption per meter for all reduced taxed contracts.
  def consumption_average_per_meter_reduced(
        total_consumption_points_reduced:,
        veeg_reduced:,
        **)
    if total_consumption_points_reduced.zero?
      return 0
    end
    veeg_reduced / total_consumption_points_reduced
  end

  # @param grid_feeding [number] Amount of grid fed electricity.
  # @param production [number] Amount of produced electricity.
  # @return [number] The calculated consumption of the own produced power.
  def consumption_own_production_wh(grid_feeding:, production:, **)
    production - grid_feeding
  end

  # @param [number] consumption
  # @return [number] The calculated consumption of grid power.
  def consumption_grid_wh(consumption:,
                          consumption_own_production_wh:,
                          **)
    consumption - consumption_own_production_wh
  end

  # @param consumption [number] Amount of electricity consumption.
  # @param grid_consumption [number] Amount of electricity consumpted through grid.
  # @return [number] the ratio of electricity produced and consumpted in percent.
  def consumption_prodcution_ratio(consumption:,
                                   grid_consumption:,
                                   **)
    (1.0 - grid_consumption / consumption) * 100
  end

  def grid_consumption(register_metas:, date_range:, warnings:, **)
    system(register_metas: register_metas, date_range: date_range, label: :grid_consumption, warnings: warnings).round(2).to_f
  end

  def contracts_with_range(params:, register_metas:, date_range:, **)
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
  def total_contracts_third_party(contracts_with_range:, **)
    contracts_with_range.select {|r| r[:contract].is_a? Contract::LocalpoolThirdParty}.count
  end

  # @param [number] contracts_with_range_and_readings Accumulated consumption of
  #                 third party contracts.
  # @return [number] Consumption of third party contracts in wh.
  def consumption_third_party(contracts_with_range_and_readings:,
                              **)
    contracts_with_range_and_readings[:third_party_wh]
  end

  # @param [number] total_contracts_third_party Number of third party contracts.
  # @param [number] contracts_with_range_and_readings Accumulated consumption of
  #                 third party contracts.
  # @return [number] Average consumption of third party contract.
  def consumption_third_party_average(total_contracts_third_party:,
                                      contracts_with_range_and_readings:,
                                      **)
    if total_contracts_third_party.zero?
      return 0
    end

    contracts_with_range_and_readings[:third_party_wh] / total_contracts_third_party
  end

  # @param  [Array] The contracts in taken into account.
  #
  # @return Accumulated price in cents.
  def baseprice_per_year_ct(contracts_with_range:, **)
    baseprices = contracts_with_range.map {|c| c[:contract]}
                                     .flat_map(&:tariffs)
                                     .map(&:baseprice_cents_per_month_before_taxes)
                                     .uniq

    if baseprices.count != 1
      raise 'Platform can not yet handle groups with more or less than one baseprice.'
    end

    baseprices.first * 12
  end

  # Das muss alle tarife zeigen und alle mitglieder die den haben
  def energyprice_cents_per_kwh_before_taxes(contracts_with_range:, **)
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
