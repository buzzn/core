#usage: copy a file called "h0.txt" into /db/slp/YEAR whereas YEAR is the year of the data (e.g. 2016)
#run bundle exec rake slp:import_h0[YEAR]

namespace :slp do
  desc 'This adds slp values to the db'
  task :import_h0, [:year] => :environment do |t, args|
    puts "Creating SLP"
    if args[:year].nil?
      year = Time.current.year.to_s
    else
      year = args[:year].to_s
    end

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
          if Reading.where(source: 'slp').where(timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString)).size == 1
            puts "Data at " + ActiveSupport::TimeZone["Berlin"].parse(dateString).to_s + " already available, trying next."
          else
            Reading.create(
              timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
              energy_milliwatt_hour: watt_hour,
              power_milliwatt: watts,
              source: "slp"
            )
          end
        elsif parseString.include? "QTY"
          additional_watt_hour = parseString[8...parseString.length].to_f*1000 #convert to mWh
          new_watt_hour = watt_hour + additional_watt_hour
          watts = (new_watt_hour - watt_hour)*4
          watt_hour += additional_watt_hour
        end
      end
    end
  end
end
