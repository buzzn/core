require_relative '../admin_roda'

module Admin
  # Creates an excel spreadsheet containing all meters and a column to note meter readings.
  class ReadingsTableRoda < BaseRoda

    plugin :shared_vars

    include Import.args[:env, create: 'transactions.admin.reading.create']

    def labels
      {
        'GRID_FEEDING' => 'ÜGZ Bezug',
        'GRID_CONSUMPTION'=> 'ÜGZ Einspeisung',
        'PRODUCTION_WATER'=> 'Produktion',
        'PRODUCTION_PV'=> 'Produktion'
      }
    end

    def create_cell(column, content, bold: false)
      cell = @sheet.add_cell(@line, column, content)
      cell.change_font_bold(bold)

      if (@line % 2).zero?
        cell.change_fill('d3d3d3')
      end

      cell
    end

    def add_entry(
      id: '',
      msb: '',
      meter_number: '',
      meter_location_description: '',
      address_additional_info: '',
      contract_additional_info: '',
      obis: ''
    )
      @line += 1
      column = 0
      create_cell(column, msb)
      column += 1
      create_cell(column, meter_number)
      column += 1
      create_cell(column, meter_location_description)
      column += 1
      create_cell(column, address_additional_info)
      column += 1
      create_cell(column, contract_additional_info)
      column += 1
      create_cell(column, obis)
      column += 1
      create_cell(column, '')
      column += 1
      cell = create_cell(column, '')
      cell.set_number_format('d.m.yyyy')
      column += 1
      create_cell(column, id)
    end

    def create_table_head(localpool)
      column = 0
      # Table info
      create_cell(column, localpool.name, bold: true)
      column += 3
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, '')

      @line += 1

      # Table head
      column = 0
      create_cell(column, 'MSB-id', bold: true)
      column += 1
      create_cell(column, 'Zählernummer', bold: true)
      @sheet.change_column_width(column, 40)
      column += 1
      create_cell(column, 'Installationsort', bold: true)
      @sheet.change_column_width(column, 20)
      column += 1
      create_cell(column, 'Zusatz', bold: true)
      @sheet.change_column_width(column, 20)
      column += 1
      create_cell(column, 'Label', bold: true)
      @sheet.change_column_width(column, 30)
      column += 1
      create_cell(column, 'Obis', bold: true)
      column += 1
      create_cell(column, 'Zählerstand in kWh', bold: true)
      @sheet.change_column_width(column, 20)
      column += 1
      create_cell(column, 'Ablesedatum', bold: true)
      @sheet.change_column_width(column, 30)
      column += 1
      create_cell(column, 'Buzzn-Register-Id', bold: true)
      @sheet.change_column_width_raw(column, 0)
    end

    def create_sheet(localpool)
      workbook = RubyXL::Workbook.new
      @sheet = workbook.worksheets[0]
      @sheet.sheet_name='Report'
      @sheet.merge_cells(0, 0, 0, 2)
      @sheet.merge_cells(0, 3, 0, 4)
      @line = 0
      create_table_head(localpool)

      localpool.active_meters.each do |meter|
        meter.registers.each do |register|
          register_meta = register.register_meta


          unless register&.register_meta&.label.nil?
            contract_additional_info = register.register_meta.label
          end

          add_entry(
            id: register.id,
            msb: meter.sequence_number,
            meter_number: meter.product_serialnumber, # Zählernummer
            meter_location_description: meter.location_description, # Installationsort
            address_additional_info: register_meta&.name,
            contract_additional_info: contract_additional_info,
            obis: register.obis
          )
        end
      end

      workbook
    end

    def create_filename(localpool)
      date_string = Time.now.strftime('%Y-%m-%d')
      "#{date_string}_Energiegruppe #{localpool.name}.xlsx"
    end

    def read_sheet(localpool, file)
      workbook = RubyXL::Parser.parse_buffer(file)
      sheet = workbook[0]

      result = {errors: [], warnings: []}

      register_by_id = {}

      localpool.meters.flat_map(&:registers).each do |r|
        register_by_id[r.id] = r
      end

      # Skip headline, roll over all the data rows
      (2...sheet.count).each do |i|
        if sheet[i].nil?
          next
        end

        linum = i + 1
        register_id = sheet[i][8]&.value
        date_of_reading =  sheet[i][7]&.value
        reading_value = sheet[i][6]&.value

        if register_id.nil? && date_of_reading.nil? && reading_value .nil?
          next
        end

        if register_id.nil?
          result[:errors].append "Buzzn-Register-Id is missing in row #{linum}"
          next
        end

        if date_of_reading.nil?
          result[:errors].append "Date not found in #{linum}"
          next
        end

        unless date_of_reading.is_a? Date
          result[:errors].append "'#{date_of_reading.to_s}' is not a valid date in #{linum}"
          next
        end

        target_register = register_by_id[register_id]
        if target_register.nil?
          result[:errors].append "Buzzn-Register-Id '#{register_id}' not found in group #{localpool.name} in row #{linum}"
          next
        end

        if reading_value.nil?
          result[:errors].append "No reading value found in row #{linum}"
          next
        end

        unless reading_value.is_a? Numeric
          result[:errors].append "Reading '#{reading_value}' is not formated as a number in row #{linum}"
          next
        end

        if target_register.readings.size.zero?
          create.(resource: target_register,
            params: {
              reason: 'IOM',
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

        reading = {}
        reading[:status] = 'Z86'
        reading[:reason] = 'COT'
        reading[:read_by] = 'SG'
        reading[:quality] = '220'
        reading[:unit] = 'Wh'
        reading[:source] = 'MAN'
        reading[:comment] = ''
        reading[:date] = date_of_reading
        reading[:raw_value] = BigDecimal(reading_value) * 1000

        begin
          create.(resource: target_register, params: reading)
        rescue ActiveRecord::RecordNotUnique => e
          result[:errors].append "Error in line #{linum}: There is already a reading for the date."
        rescue Exception => e
          result[:errors].append "Error creating reading for register in #{linum}: #{e.class.name} #{e.message}"
        end
      end

      result
    end

    route do |r|
      localpool = shared[:localpool]
      r.get! do
        filename = create_filename(localpool)
        r.response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        r.response.headers['Content-Disposition'] = "inline; filename=\"#{filename}\""
        r.response.write(create_sheet(localpool).stream.string)
      end

      r.post! do
        r.response.headers['Content-Type'] = 'application/json'
        read_sheet(shared[:localpool], r.body).to_json
      end
    end
  end
end
