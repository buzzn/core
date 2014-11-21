namespace :slp do
  desc 'This adds slp values to the db'
  task :import_h0, [:year] => :environment do |t, args|
    puts "Creating SLP"
    lastReading = Reading.where(source: "slp").last
    if !lastReading.nil?
      if lastReading.timestamp.year.to_s == args[:year].to_s
        puts "SLP for " + args[:year] + " already available."
      end
    else
      infile = File.new("#{Rails.root}/db/slp/" + args[:year].to_s + "/h0.txt", "r")
      all_lines = infile.readline
      infile.close
      watt_hour = 0.0
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
              watt_hour: watt_hour,
              source: "slp"
            )
          elsif parseString.include? "QTY"
            watt_hour += parseString[8...parseString.length].to_f
            watt_hour = watt_hour.round(3)
          end
        end
      end
    end
  end
end

