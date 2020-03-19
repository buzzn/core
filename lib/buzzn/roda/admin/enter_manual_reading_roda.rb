require_relative '../admin_roda'

module Admin
  # Imports manual readings from a given excel spreadsheet.
  class EnterManualReadingRoda < BaseRoda

    include Import.args[:env,
                        create: 'transactions.admin.reading.create',
                        book: 'transactions.admin.accounting.book',
                        create_electricity_labelling: 'transactions.admin.report.create_electricity_labelling'
    ]

    plugin :shared_vars

    def value_or_empty(cell, empty = '')
      if cell.nil?
        empty
      else
        cell.value
      end
    end

    def read_sheet(localpool, file)
      workbook = RubyXL::Parser.parse_buffer(file)
      sheet = workbook[0]

      date_of_reading = DateTime.new(2019, 12, 31)

      if !sheet[0][5].value.nil? && (sheet[0][5].value.is_a? DateTime)
        date_of_reading = sheet[0][5].value # todo adjust to a usfull default date
      end

      name_of_group = sheet[0][0].value

      target_pools = LocalpoolResource.all(current_user).select {|x| x.name == name_of_group}

      reading_errors = []
      if target_pools.empty?
        reading_errors.append "No group found namend #{name_of_group}"
        return {errors: reading_errors}
      end

      if target_pools.size > 1
        reading_errors.append "Group name is ambigous: #{name_of_group}"
        return {errors: reading_errors}
      end

      if target_pools.first.id != localpool.id
        reading_errors.append "This is group #{localpool.name}, the provided sheet refers to group #{target_pools.first.name}"
        return {errors: reading_errors}
      end

      meters_by_serial = {}

      target_pools.first.meters.each do |meter|
        meters_by_serial[meter.product_serialnumber] = meter
      end

      # Skip headline, roll over all the data rows
      (2...sheet.count).each do |i|
        register_number = sheet[i][3].value
        register_addition = value_or_empty sheet[i][5]
        paid_abatement = value_or_empty sheet[i][10]
        contract_number = value_or_empty sheet[i][0]

        reading_comment = value_or_empty(sheet[i][12], 'Yearly reading imported from excel sheet')

        if meters_by_serial[register_number].nil?
          reading_errors.append "Unknown register number '#{register_number}' for contract #{contract_number}"
          next
        end
        skip_abatement = false
        # And the meters here
        if meters_by_serial[register_number].registers.size > 1
          target_meter = meters_by_serial[register_number]

          target_registers = []
          if register_addition == 'Produktion'
            target_registers = target_meter.registers.select {|reg| reg.register_meta.label.start_with?('PRODUCTION')}
            skip_abatement = true
          elsif register_addition == 'ÜGZ Bezug'
            target_registers = target_meter.registers.select {|reg| reg.register_meta.label == 'GRID_FEEDING'}
            skip_abatement = true
          elsif register_addition == 'ÜGZ Einspeisung'
            target_registers = target_meter.registers.select {|reg| reg.register_meta.label == 'GRID_CONSUMPTION'}
            skip_abatement = true
          end

          if target_registers.empty?
            reading_errors.append "Can not find suiting register #{register_number}. Skipping..."
            next
          elsif target_registers.size > 1
            reading_errors.append "Register #{register_number} ambigous. Skipping..."
            next
          else
            register = target_registers.first
          end
        else
          register = meters_by_serial[register_number].registers.first
        end

        if skip_abatement
          next
        end

        #fill_paid_abatement(paid_abatement, contract_number)
        contract = register.contracts.select {|c| c.full_contract_number == contract_number}.first

        # It happens that the register is not attached to any contract, but the contract we are after is in the pools contracts.
        if contract.nil?
          contract = target_pools.first.contracts.select {|x| x.full_contract_number == contract_number}.first
        end

        if ['X', 'x'].include?(paid_abatement)
          # X means skip this one
        elsif paid_abatement.nil? || paid_abatement == '' ||  paid_abatement == '0'
          # No value means just balance the account
          paiment_missing = contract.balance_sheet.total * -1
          book.(resource: contract.accounting_entries, params:
            {
              :comment => 'Ausgleich',
              :amount => paiment_missing, # paiment expects value in ct.
              :booked_by => current_user
            })
        elsif !paid_abatement.is_a? Numeric
          reading_errors.append "Register #{register_number}: Requested paiment '#{paid_abatement}' is not a number."
        elsif contract.nil?
          reading_errors.append "No contract found for #{register_number}."
        else
          paiment_missing = contract.balance_sheet.total * -1
          book.(resource: contract.accounting_entries, params:
            {
              :comment => 'Ausgleich',
              :amount => paiment_missing, # paiment expects value in ct.
              :booked_by => current_user
            })
          book.(resource: contract.accounting_entries, params:
            {
              :comment => "Bezahlte Abschläge #{date_of_reading.year}",
              :amount => paid_abatement * 1000, # paiment expects value in 1/10 ct.
              :booked_by => current_user
            })
        end

        begin
          if register.readings.size.zero?
            create.(resource: register, params: {
                      reason: 'PMR',
                      read_by: 'SG',
                      quality: '220',
                      unit: 'Wh',
                      source: 'MAN',
                      comment: 'Geräteeinbau',
                      raw_value: 0,
                      status: 'Z86',
                      date: localpool.start_date
                    })
          end

          unless sheet[i][9].value == ''
            reading = {}
            reading[:status] = 'Z86'
            reading[:reason] = 'PMR'
            reading[:read_by] = 'SG'
            reading[:quality] = '220'
            reading[:unit] = 'Wh'
            reading[:source] = 'MAN'
            reading[:comment] = reading_comment
            reading[:date] = date_of_reading
            reading[:raw_value] = sheet[i][9].value * 1000

            if sheet[i][9].value.is_a? Numeric
              create.(resource: register, params: reading)
            else
              reading_errors.append "Can not create reading for register #{register_number} due '#{sheet[i][9].value}' is not a number"
            end
          end
        rescue ActiveRecord::RecordNotUnique
          reading_errors.append "There is already a reading for register #{register_number}. Skipping..."
        rescue StandardError => e
          reading_errors.append "Can not create reading for register #{register_number} due to #{e.message}."
        end
      end

      begin
        result = create_electricity_labelling.(resource: target_pools.first,
                                               params: {begin_date: Time.parse('2019-01-01T00:00:00.882Z'),
                                                        last_date: Time.parse('2020-01-01T00:01:00.000Z')})

        warnings = []
        unless result.value[:warnings].nil?
          warnings.concat(result.value[:warnings].map(&:to_s))
        end

        consumption_eeg_reduced = (result.value[:consumption_eeg_reduced]/1000).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1\'').reverse
        consumption_eeg_full = (result.value[:consumption_eeg_full]/1000).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1\'').reverse
        consumption_without_third_party = (result.value[:consumption_without_third_party]/1000).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1\'').reverse
        production = (result.value[:production]/1000).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1\'').reverse
        production_consumend_in_group_kWh = (result.value[:production_consumend_in_group_kWh]/1000).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1\'').reverse
        return {
          errors: ["LSN als Letztverbraucher #{consumption_eeg_full}kWh",
                   "LSG als Letztverbraucher #{consumption_eeg_reduced}kWh",
                   "Verbrauchsmenge gesamt #{consumption_without_third_party}kWh",
                   "Upstream 3: Produktion gesamt #{production}",
                   "Summe: Upstream 1: Produktion, die in LEG verbraucht wurde #{production_consumend_in_group_kWh}"].concat(reading_errors),
          fakeStats: result.value,
          warnings: warnings
        }
      rescue Exception => e
        reading_errors.append "Could not generate new fake stats due to #{e.message}"
        return {
          errors: reading_errors
        }
      end
    end

    route do |r|
      r.post! do
        r.response.headers['Content-Type'] = 'application/json'
        read_sheet(shared[:localpool], r.params['file'][:tempfile]).to_json
      end
    end

  end
end
