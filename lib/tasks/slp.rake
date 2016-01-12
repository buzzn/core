namespace :slp do
  desc 'This adds slp values to the db'
  task :import_h0, [:year] => :environment do |t, args|
    puts "Creating SLP"
    if args[:year].nil?
      year = Time.now.year.to_s
    else
      year = args[:year].to_s
    end
    count_readings = Reading.where(source: "slp").size
    lastReading = Reading.where(source: "slp")[count_readings - 1]
    if !lastReading.nil? && lastReading.timestamp.year.to_s == year
      puts "SLP for " + year + " already available."
    else
      infile = File.new("#{Rails.root}/db/slp/" + year + "/h0.txt", "r")
      all_lines = infile.readline
      infile.close
      watt_hour = 0.0
      watts = 0.0
      while true do
        posOfSeperator = all_lines.index("'")
        if posOfSeperator == nil
          break
        else
          parseString = all_lines[0...posOfSeperator]
          all_lines = all_lines[(posOfSeperator + 1)..all_lines.length]
          if parseString.include? "DTM+163"
            remString = parseString[8..parseString.length]
            dateString = remString[0..3] + "-" + remString[4..5] + "-" + remString[6..7] + " " + remString[8..9] + ":" + remString[10..11]
            Reading.create(
              timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
              watt_hour: watt_hour*10000000.0, #convert from Wh to 10^-10 kWh
              power: watts,
              source: "slp"
            )
          elsif parseString.include? "QTY"
            additional_watt_hour = parseString[8...parseString.length].to_f
            new_watt_hour = watt_hour + additional_watt_hour
            watts = (new_watt_hour - watt_hour)*4*1000 #convert to mW
            watt_hour += additional_watt_hour
            watt_hour = watt_hour.round(3)
          end
        end
      end
    end
  end
end

