# coding: utf-8
require_relative '../report'
require_relative './report_data.rb'
require_relative '../../../schemas/transactions/admin/report/create_annual_report'
require_relative '../../../transactions'

require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

# Creates an annual report as an excel sheet of a given group.
class Transactions::Admin::Report::CreateAnnualReport < Transactions::Admin::Report::ReportData

  validate :schema
  # authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  add :warnings

  add :date_range
  add :register_metas

  add :contracts_with_range
  add :contracts_with_range_and_readings
  add :total_contracts_third_party
  add :consumption_third_party
  add :consumption_third_party_average


  add :period
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
  add :total_contracts_third_party
  add :consumption_third_party_average
  add :baseprice_per_year_ct
  add :energyprice_cents_per_kwh_before_taxes

  add :generate_report_file
  add :init_document

  map :build_result2

  def schema
    Schemas::Transactions::Admin::Report::CreateAnnualReport
  end

  def allowed_roles(permission_context:)
    #    permission_context.reports.annual_report.create
  end

  def warnings(**)
    []
  end

  def period(params:, resource:, **)
    #if params[:end] <= params[:begin]
    #  raise Buzzn::ValidationError.new(begin: ['must be before end'])
    #end
    #params.delete(:begin)...params.delete(:end)
    Time.local(2018, 1, 1)...Time.local(2018, 12, 31)
  end

  def register_metas(resource:, **)
    resource.object.register_metas_by_registers.uniq # Todo add doc: why uniq?
  end

  def init_document() end

  def add_value(value, unit = '')
    @sheet.add_cell(@line, @result_column, value)
    @sheet.add_cell(@line, @result_column+1, unit)
  end

  # Converts a value to human readable and adds a value it into the sheet.
  #
  # @param [number] value to be added in cent.
  def add_value_cent(value)
    if value.nil?
      value = 0
    end

    if value > 99
      add_value(value/100, 'Euro')
    else
      add_value(value, 'ct')
    end
  end

  # Converts a value to a human readable (kWh, mWh, gWh, tWh),
  # and adds it into the sheet.
  #
  # @param [number] value to be added in wh.
  def add_value_wh(value)
    units = {
      10**12 => 'tWh',
      10**9 => 'gWh',
      10**6 => 'mWh',
      10**3 => 'kWh'
    }

    if value.nil?
      add_value_wh(0)
    end

    units.each do |size, unit|
      if value > size
        add_value(value/size, unit)
        return
      end
    end
    add_value(value, 'Wh')
  end

  # Generates the annual report using the given report data.
  #
  # @param resource The report's group.
  # @param report_data [Hash] All the data to show in the report.
  # @return A stream of an excel sheet.
  def generate_report_file(resource:,
                           production:,
                           production_chp:,
                           production_pv:,
                           consumption_common:,
                           production_usage_ratio:,
                           grid_feeding:,
                           grid_feeding_chp:,
                           grid_feeding_pv:,
                           consumption:,
                           veeg:,
                           total_consumption_points_full:,
                           consumption_average_per_meter_full:,
                           veeg_reduced:,
                           total_consumption_points_reduced:,
                           consumption_average_per_meter_reduced:,
                           consumption_own_production_wh:,
                           consumption_grid_wh:,
                           consumption_prodcution_ratio:,
                           consumption_third_party:,
                           total_contracts_third_party:,
                           consumption_third_party_average:,
                           baseprice_per_year_ct:,
                           energyprice_cents_per_kwh_before_taxes:,
                           **)
    workbook = RubyXL::Workbook.new
    @sheet = workbook.worksheets[0]
    @sheet.sheet_name='Report'
    @line = 0
    @result_column = 10
    cell = @sheet.add_cell(@line, 0,
                           'Lokale Energiegruppe ' + resource.name + ' - Report ')
    cell.change_font_size(20)
    @sheet.change_row_height(@line, 20)
    @sheet.merge_cells(@line, 0, @line, 20)

    (0...@result_column-1).each {|c| @sheet.change_column_width(c, 3)}
    @sheet.change_column_width(@result_column-1, 25)

    @line += 1
    cell = @sheet.add_cell(@line, 0, 'Strommengen ')
    cell.change_font_bold(true)

    @line += 1
    @sheet.add_cell(@line, 1, 'Eigenstromproduktion gesamt')
    add_value_wh(production)

    @line += 1
    @sheet.add_cell(@line, 2, 'davon aus Blockheizkraftwerk (BHKW)')
    add_value_wh(production_chp)

    @line += 1
    @sheet.add_cell(@line, 2, 'davon aus Photovoltaikanlage (PVA)')
    add_value_wh(production_pv)

    @line += 1
    @sheet.add_cell(@line, 2, 'Gruppen intern verbraucht')
    add_value_wh(consumption_common)

    @line += 1
    @sheet.add_cell(@line, 2, 'Nutzungsgrad')
    add_value(production_usage_ratio, '%')

    @line += 1
    @sheet.add_cell(@line, 1, 'ins Netz eingespeist (Überschussstrom)')
    add_value_wh(grid_feeding)

    @line += 1
    @sheet.add_cell(@line, 2, 'davon aus Blockheizkraftwerk (BHKW)')
    add_value_wh(grid_feeding_chp)

    @line += 1
    @sheet.add_cell(@line, 2, 'davon aus Photovoltaikanlage (PVA)')
    add_value_wh(grid_feeding_pv)

    @line += 2
    @sheet.add_cell(@line, 1, 'Verbrauch gesamt')
    add_value_wh(consumption)

    @line += 1
    @sheet.add_cell(@line, 2, 'durch Verbrauchsstellen (volle EEG-Umlage)')
    add_value_wh(veeg)

    @line += 1
    @sheet.add_cell(@line, 3, 'Anzahl Verbrauchsstellen')
    add_value(total_consumption_points_full, 'Stk.')

    @line += 1
    @sheet.add_cell(@line, 3, 'Mittelwert')
    add_value_wh(consumption_average_per_meter_full)

    @line += 1
    @sheet.add_cell(@line, 2, 'durch Verbrauchsstellen (reduzierte EEG-Umlage)')
    add_value_wh(veeg_reduced)

    @line += 1
    @sheet.add_cell(@line, 3, 'Anzahl Verbrauchsstellen')
    add_value(total_consumption_points_reduced, 'Stk.')

    @line += 1
    @sheet.add_cell(@line, 3, 'Mittelwert')
    add_value_wh(consumption_average_per_meter_reduced)

    @line += 1
    @sheet.add_cell(@line, 2, 'gedeckt durch')

    @line += 1
    @sheet.add_cell(@line, 3, 'Eigenstrom (eigene Produktion)')
    add_value_wh(consumption_own_production_wh)

    @line += 1
    @sheet.add_cell(@line, 3, 'Zusatzstrombezug (aus dem Netz)')
    add_value_wh(consumption_grid_wh)

    @line += 1
    @sheet.add_cell(@line, 3, 'Deckungsgrad')
    add_value(consumption_prodcution_ratio, '%')

    @line += 2
    @sheet.add_cell(@line, 1, 'Verbrauchsstellen Drittbelieferte gesamt')
    add_value_wh(consumption_third_party)

    @line += 1
    @sheet.add_cell(@line, 2, 'Anzahl Verbrauchsstellen Drittbelieferte')
    add_value(total_contracts_third_party)

    @line += 1
    @sheet.add_cell(@line, 2, 'Mittelwert')
    add_value_wh(consumption_third_party_average)

    # Preise
    @line += 1
    @sheet.add_cell(@line, 0, 'Preise (Alle Angaben ohne Ust. )')
    cell.change_font_bold(true)

    @line += 1
    @sheet.add_cell(@line, 1, 'Gruppen intern')

    @line += 1
    @sheet.add_cell(@line, 2, 'Grundpreis')
    add_value_cent(baseprice_per_year_ct)

    @line += 1
    @sheet.add_cell(@line, 2, 'Arbeitspreis')
    add_value_cent(energyprice_cents_per_kwh_before_taxes)

    @line += 1
    @sheet.add_cell(@line, 1, 'Zusatzstrom')

    @line += 1
    @sheet.add_cell(@line, 2, 'Lieferant, Tarif')

    @line += 1
    @sheet.add_cell(@line, 2, 'Grundpreis')

    @line += 1
    @sheet.add_cell(@line, 2, 'Arbeitspreis')

    @line += 1
    @sheet.add_cell(@line, 1, 'Überschussstrom')

    @line += 1
    @sheet.add_cell(@line, 2, 'Grundpreis (für Abrechnung)')

    @line += 1
    @sheet.add_cell(@line, 2, 'KWK Vergütung Einspeisung (EEX + KWK Bonus)')

    @line += 1
    @sheet.add_cell(@line, 2, 'KWK Vergütung Eigenverbrauch (KWK Bonus)')

    @line += 1
    @sheet.add_cell(@line, 2, 'Einspeisevergütung PV')

    @line += 1
    @sheet.add_cell(@line, 1, 'EEG-Umlage')

    @line += 1
    @sheet.add_cell(@line, 2, 'auf Verbrauchsstellen (EEG-Umlage behaftet)')

    @line += 1
    @sheet.add_cell(@line, 2, 'auf Verbrauchsstellen (EEG-Umlage reduziert)')

    @line += 1
    @sheet.add_cell(@line, 1, 'Dienstleistung BUZZN')

    @line += 1
    @sheet.add_cell(@line, 2, 'Anzahl Messstellen gesamt')

    @line += 1
    @sheet.add_cell(@line, 3, 'davon mit Einrichtungszähler')

    @line += 1
    @sheet.add_cell(@line, 4, 'laufende Vergütung')

    @line += 1
    @sheet.add_cell(@line, 3, 'davon mit Zweirichtungszähler')

    @line += 1
    @sheet.add_cell(@line, 4, 'laufende Vergütung')

    # Einahmen Ausgaben
    @line += 2
    cell = @sheet.add_cell(@line, 0, 'Einnahmen / Ausgaben')
    cell.change_font_bold(true)

    @line += 1
    @sheet.add_cell(@line, 1, 'Erlöse gesamt')

    @line += 1
    @sheet.add_cell(@line, 2, 'durch Stromverkauf an die Verbrauchsstellen')

    @line += 1
    @sheet.add_cell(@line, 3, 'durch Arbeitsmenge')

    @line += 1
    @sheet.add_cell(@line, 3, 'durch Grundpreis')

    @line += 1
    @sheet.add_cell(@line, 2, 'durch Netzbetreiber')

    @line += 1
    @sheet.add_cell(@line, 1, 'Kosten gesamt')

    @line += 1
    @sheet.add_cell(@line, 2, 'EEG-Umlage')

    @line += 1
    @sheet.add_cell(@line, 2, 'Zusatzstromlieferung')

    @line += 1
    @sheet.add_cell(@line, 2, 'Dienstleistung BUZZN laufend')

    workbook.stream
  end

  def build_result2(generate_report_file:, **)
    generate_report_file
  end

end

