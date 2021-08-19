require_relative '../admin_roda'

module Admin
  # Creates an excel spreadsheet containing all meters and a column to note meter readings.
  class ManualReadingDocumentsRoda < BaseRoda

    include Import.args[:env,
                        mail_service: 'services.mail_service'
    ]

    plugin :shared_vars

    def labels
      {
        'GRID_FEEDING' => 'ÜGZ Einspeisung',
        'GRID_CONSUMPTION'=> 'ÜGZ Bezug',
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
      contract_number: '',
      msb: '',
      renter_number: '',
      meter_number: '',
      meter_location_description: '',
      contract_additional_info: '',
      first_name: '',
      last_name: '',
      address_additional_info: '',
      meter_reading_requested: true,
      paid_requested: true,
      billnumber_requested: true
    )
      @line += 1
      column = 0
      create_cell(column, contract_number)
      column += 1
      create_cell(column, msb)
      column += 1
      create_cell(column, renter_number)
      column += 1
      create_cell(column, meter_number)
      column += 1
      create_cell(column, meter_location_description)
      column += 1
      create_cell(column, contract_additional_info)
      column += 1
      create_cell(column, first_name)
      column += 1
      create_cell(column, last_name)
      column += 1
      create_cell(column, address_additional_info)

      column += 1
      if meter_reading_requested
        create_cell(column, '')
      else
        create_cell(column, 'X')
      end
      column += 1

      if paid_requested
        create_cell(column, '')
      else
        create_cell(column, 'X')
      end
      column += 1

      if billnumber_requested
        create_cell(column, '')
      else
        create_cell(column, 'X')
      end
    end

    def create_table_head(localpool)
      column = 0
      # Table info
      create_cell(column, localpool.name, bold: true)
      column += 3
      create_cell(column, 'Datum der Ablesung', bold: true)
      column += 1
      create_cell(column, '')
      column += 1
      create_cell(column, "31.12.#{Date.today.year}")
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
      create_cell(column, 'Vertragsnummer', bold: true)
      @sheet.change_column_width(column, 19)
      column += 1
      create_cell(column, 'MSB-id', bold: true)
      column += 1
      create_cell(column, 'Mieternummer', bold: true)
      column += 1
      create_cell(column, 'Zählernummer', bold: true)
      column += 1
      @sheet.change_column_width(column, 20)
      create_cell(column, 'Installationsort', bold: true)
      @sheet.change_column_width(column, 20)
      column += 1
      create_cell(column, 'Zusatz', bold: true)
      @sheet.change_column_width(column, 20)
      column += 1
      create_cell(column, 'Vorname', bold: true)
      @sheet.change_column_width(column, 12)
      column += 1
      create_cell(column, 'Nachname', bold: true)
      @sheet.change_column_width(column, 12)
      column += 1
      create_cell(column, 'Adresszusatz', bold: true)
      @sheet.change_column_width(column, 30)
      column += 1
      create_cell(column, 'Zählerstand	', bold: true)
      @sheet.change_column_width(column, 20)
      column += 1
      create_cell(column, 'bezahlte Abschläge in €', bold: true)
      @sheet.change_column_width(column, 30)
      column += 1
      create_cell(column, 'Rechnungsnummer', bold: true)
      @sheet.change_column_width(column, 21)
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
        meter.registers.select {|rm| rm.contracts.any? {|c| c.status == 'active'}}.each do |register|

          register_meta = register.register_meta
          paid_requested = true
          billnumber_requested = true

          # We filtered those which do have a valid contract before, so there must be exactly one!
          contract = register_meta.contracts.select {|c| c.status == 'active'}[0]
          if contract.is_a?(Contract::LocalpoolPowerTakerResource)
            contract_additional_info = 'Bezug'
          elsif contract.is_a?(Contract::LocalpoolThirdPartyResource)
            contract_additional_info = 'Drittbeliefert'
            paid_requested = false
            billnumber_requested = false
          end

          unless contract.customer.nil?
            if contract.customer.is_a? PersonResource
              first_name = contract.customer.first_name
              last_name = contract.customer.last_name
            else
              last_name = contract.customer.name
            end
          end

          add_entry(
            contract_number: contract.full_contract_number, # Vertragsnummer
            msb: meter.sequence_number,
            renter_number: contract.third_party_renter_number, # Mieternummer
            meter_number: meter.product_serialnumber, # Zählernummer
            meter_location_description: meter.location_description, # Installationsort
            contract_additional_info: contract_additional_info, # Zusatz
            first_name: first_name,
            last_name: last_name,
            address_additional_info: register_meta.name,
            paid_requested: paid_requested,
            billnumber_requested: billnumber_requested
          )
        end
      end

      localpool.active_meters.reject {|m| m.is_a?(Meter::VirtualResource)}
               .reject {|m| m.registers.all? {|register| register.contracts.any? {|c| c.status == 'active'}}}
               .reject {|m| m.registers.all? {|register| register.contracts.to_a.empty?}}
               .each do |meter|
        meter.registers.each do |register|
          if register.register_meta.nil?
            next
          end

          add_entry(
            contract_additional_info: 'Leerstand',
            msb: meter.sequence_number,
            meter_number: meter.product_serialnumber, # Zählernummer
            meter_location_description: meter.location_description, # Installationsort
            address_additional_info: register.register_meta.name,
            paid_requested: false
          )
        end
      end

      localpool.active_meters.reject {|m| m.is_a?(Meter::VirtualResource)}
               .select {|m| m.registers.all? {|register| register.contracts.to_a.empty?}}
               .each do |meter|
        meter.registers.each do |register|
          if register.register_meta.nil?
            next
          end

          add_entry(
            contract_additional_info: labels[register.register_meta.label],
            msb: meter.sequence_number,
            meter_number: meter.product_serialnumber, # Zählernummer
            meter_location_description: meter.location_description, # Installationsort
            address_additional_info: register.register_meta.name,
            paid_requested: false
          )
        end
      end

      workbook
    end

    def create_filename(localpool)
      date_string = Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d')
      "#{date_string}_Energiegruppe #{localpool.name} - Zaehler und Abschlaege 2020.xlsx"
    end

    route do |r|
      localpool = shared[:localpool]
      r.on 'table' do
        r.get! do
          filename = create_filename(localpool)
          r.response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          r.response.headers['Content-Disposition'] = "inline; filename=\"#{filename}\""
          r.response.write(create_sheet(localpool).stream.string)
        end
      end

      r.on 'send-mail' do
        r.get! do
         # begin
            workbook = create_sheet(localpool)
            pooldoc = Document.create(filename: create_filename(localpool),
                                      data: workbook.stream.string)
            localpool.documents << pooldoc
            pooldoc.store

            if localpool.owner.is_a?(Organization::GeneralResource)
              contact = localpool.owner.contact
            else
              contact = localpool.owner
            end

            salute = "Hallo #{contact.first_name} #{contact.last_name}"

            if contact.prefix == 'M'
              salute = "Sehr geehrter Herr #{contact.last_name}"
            elsif contact.prefix == 'F'
              salute = "Sehr geehrte Frau #{contact.last_name}"
            end

            message = <<~MSG
              #{salute},

              das Jahr 2019 neigt sich dem Ende zu und zur Erstellung der Jahresabrechnung 2019 für die Stromnehmer
              Ihrer Lokalen Energiegruppe benötigen wir Ihre Mithilfe:

              Lokale Energiegruppen ohne Fernauslesung:
              Tragen Sie bitte alle in der angehängten Exceltabelle aufgeführten Zählerstände vom 31.12.2019 in Spalte J ein.
              Tragen Sie bitte, besonders bei Abweichungen, das genaue Datum der Ablesung in Zelle F1 ein.
              Als Lokaler Stromgeber vermerken Sie bitte in der Spalte K „bezahlte Abschläge in €“ die
              im Abrechnungsjahr 2019 in Summe geleisteten monatlichen Abschlagszahlungen Ihrer Lokalen Stromnehmer.

              Lokale Energiegruppen mit Fernauslesung:
              Als Lokaler Stromgeber vermerken Sie bitte in der Spalte K der angehängten Exceltabelle („bezahlte Abschläge in €“) die
              im Abrechnungsjahr 2019 in Summe geleisteten monatlichen
              Abschlagszahlungen Ihrer Lokalen Stromnehmer.
              Wenn sämtliche Zähler in der Kundenanlage fernausgelesen werden können,
              brauchen Sie die Zählerstände in der beigefügten Exceltabelle nicht eintragen.

              Bitte machen Sie keine sonstigen Änderungen an der Exceltabelle, da diese
              automatisch eingelesen wird.

              Falls Sie von Dritten eine Aufforderung zum Zählerablesen bekommen, leiten Sie uns
              diese Aufforderung bitte weiter. Wir werden diese bearbeiten damit die Daten-Konsistenz
              gewährleistet ist.

              Bitte senden Sie uns die ausgefüllte Exceltabelle als Antwortmail nach Möglichkeit bis zum 10.01.2020 zurück.

              Falls Sie Fragen haben oder die beigefügte Exceltabelle nicht öffnen können, rufen
              Sie mich gerne an oder schreiben mir.

              Vielen Dank für Ihre Mithilfe!

              Mit freundlichen Grüßen,
              Philipp Oßwald
              BUZZN – People Power

              T: 089-416171410
              F: 089-416171499localpool
              --
              BUZZN GmbH
              Combinat 56
              Adams-Lehmann-Straße 56
              80797 München
              Registergericht: Amtsgericht München
              Registernummer: HRB 186043
              Geschäftsführer: Justus Schütze
  MSG

            mail_service.deliver_later(:from => 'team@buzzn.net',
                                       :to => contact.email,
                                       :bcc => 'team@localpool.de',
                                       :subject => 'Lokale Energiegruppe: Bitte übermitteln Sie uns Abschlagszahlungen und ggf. Zählerstände!',
                                       :text => message,
                                       :document_id => pooldoc.id)
            alright = "Sending mail to #{contact.email} for localpool #{localpool.name}"
          #rescue StandardError => e
          #  alright = e.message
          #end
          r.response.headers['Content-Type'] = 'text/plain'
          r.response.write(alright)
        end
      end
    end
  end

end
