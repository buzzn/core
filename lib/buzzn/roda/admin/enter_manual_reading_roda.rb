require_relative '../admin_roda'

module Admin
  # Imports manual readings from a given excel spreadsheet.
  class EnterManualReadingRoda < BaseRoda
    include Import.args[:env,
      create: 'transactions.admin.reading.create'
    ]

    plugin :shared_vars

    def labels
    {
    'GRID_FEEDING' => 'ÜGZ Bezug',
    'GRID_CONSUMPTION'=> 'ÜGZ Einspeisung',
    'PRODUCTION_WATER'=> 'Produktion',
    'PRODUCTION_PV'=> 'Produktion'
    }
    end

    route do |r|
        r.put! do
            workbook = RubyXL::Parser.parse_buffer(r.body)
            sheet = workbook[0]

            date_of_reading = sheet[0][5].value
              
            unless date_of_reading.is_a? DateTime 
              throw "No Date found for Date of reading, found value ${date_of_reading}"
            end

            name_of_group = sheet[0][0].value

            target_pools = Group::Localpool.select{|x| x.name == name_of_group}
            
            if target_pools.size < 1
              throw "No group found namend #{name_of_group}"
            end

            if target_pools.size > 1
              throw "Group name is ambigous: #{name_of_group}"
            end

            meters_by_serial = {}
            target_pools.first.registers.map(&:meter).each do |meter|
              meters_by_serial[meter.product_serialnumber] = meter
            end

            # {"status"=>"Z86", "reason"=>"PMR", "read_by"=>"SG", "quality"=>"220", "unit"=>"Wh", "raw_value"=>1234567000, "date"=>"2020-01-07", 
            #"source"=>"MAN", "comment"=>"jawol"}
            
            for i in 2 ... sheet.count-1  do
              reading = {}
              reading[:status] = "Z86"
              reading[:reason] = "PMR"
              reading[:read_by] = "SG"
              reading[:quality] = "220"
              reading[:unit] = "Wh"
              reading[:source] = "MAN"
              reading[:comment] = "Yearly reading imported from excel sheet"
              reading[:date] = date_of_reading

              reading[:raw_value] = sheet[i][9].value
              register_number = sheet[i][3].value

              print("bam #{i}  #{register_number}   x")
              register = meters_by_serial[register_number].registers.first
              create.(resource: register, 
                params: reading)
            end
        end        
    end
  end
end
