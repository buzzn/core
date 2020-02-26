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

    def value_or_empty(cell, empty='')
      if cell.nil?
        empty
      else
        cell.value
      end
    end

    def read_sheet(localpool, file)
      workbook = RubyXL::Parser.parse_buffer(file)
      sheet = workbook[0]

      date_of_reading = sheet[0][5].value

      unless date_of_reading.is_a? DateTime
        date_of_reading = DateTime.new(2019, 12, 31) # todo adjust to a usfull default date
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

        # And the meters here
        if meters_by_serial[register_number].registers.size > 1
          target_meter = meters_by_serial[register_number]

          target_registers = []
          if register_addition == 'Produktion'
            target_registers = target_meter.registers.select {|reg| reg.register_meta.label.start_with?('PRODUCTION')}
          elsif register_addition == 'ÜGZ Bezug'
            target_registers = target_meter.registers.select {|reg| reg.register_meta.label == 'GRID_FEEDING'}
          elsif register_addition == 'ÜGZ Einspeisung'
            target_registers = target_meter.registers.select {|reg| reg.register_meta.label == 'GRID_CONSUMPTION'}
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

        #fill_paid_abatement(paid_abatement, contract_number)
        contract = register.contracts.select {|c| c.full_contract_number == contract_number}.first
        if ['X', ''].include? paid_abatement or paid_abatement.nil?
          # Skip
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
              :comment => "Bezahlte Abschläge #{date_of_reading}",
              :amount => paid_abatement * 1000, # paiment expects value in 1/10 ct.
              :booked_by => current_user
            })
        end

        begin
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

            if sheet[i][9].value.is_a? Fixnum
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
        result = create_electricity_labelling.(resource: target_pools.first, params: {'begin_date'=> '2019-01-01T00:00:00.882Z', 'last_date'=> '2020-01-10T00:01:00.000Z'})
        return {
          errors: reading_errors,
          fakeStats: result.value
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
