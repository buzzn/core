#usage: copy a file called "sep_pv_jahresband.scv" into /db/sep/YEAR whereas YEAR is the year of the data (e.g. 2016)
#run bundle exec rake sep:import_pv_bhkw[YEAR]

namespace :sep do
  desc 'This adds sep values to the db'
  task :import_pv_bhkw, [:year] => :environment do |t, args|
    puts "Creating SEP"
    if args[:year].nil?
      year = Time.now.year.to_s
    else
      year = args[:year].to_s
    end

    infile = File.open("#{Rails.root}/db/sep/" + year + "/sep_pv_jahresband.csv", "r")

    pv_watt_hour = 0.0
    pv_watts = 0.0

    bhkw_watt_hour = 0.0
    bhkw_watts = 0.0

    infile.each_line  do |cur_line|
      date = cur_line.split(',')[0]
      time = cur_line.split(',')[1]

      dateString = (date + " " + time).delete("\"")

      if Reading.where(source: 'sep_pv').where(timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString)).size == 1
        puts "Data at " + ActiveSupport::TimeZone["Berlin"].parse(dateString).to_s + " already available, trying next."
        next
      end

      add_pv_watt_hour = cur_line.split(',')[2].delete("\"").to_f*1000000 #convert to mWh
      add_bhkw_watt_hour = cur_line.split(',')[3].delete("\"").to_f*1000000 #convert to mWh

      new_pv_watt_hour = pv_watt_hour + add_pv_watt_hour
      pv_watts = (new_pv_watt_hour - pv_watt_hour)*4
      pv_watt_hour += add_pv_watt_hour
      Reading.create(
        timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
        energy_a_milliwatt_hour: pv_watt_hour,
        power_a_milliwatt: pv_watts,
        source: "sep_pv"
      )

      new_bhkw_watt_hour = bhkw_watt_hour + add_bhkw_watt_hour
      bhkw_watts = (new_bhkw_watt_hour - bhkw_watt_hour)*4
      bhkw_watt_hour += add_bhkw_watt_hour
      Reading.create(
        timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
        energy_a_milliwatt_hour: bhkw_watt_hour,
        power_a_milliwatt: bhkw_watts,
        source: "sep_bhkw"
      )


      # else
      #   parseString = all_lines[0...posOfSeperator]
      #   all_lines = all_lines[(posOfSeperator + 1)..all_lines.length]
      #   if parseString.include? "DTM+163"
      #     remString = parseString[8..parseString.length]
      #     dateString = remString[0..3] + "-" + remString[4..5] + "-" + remString[6..7] + " " + remString[8..9] + ":" + remString[10..11]
      #     Reading.create(
      #       timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
      #       watt_hour: watt_hour*10000000.0, #convert from Wh to 10^-10 kWh
      #       power: watts,
      #       source: "slp"
      #     )
      #   elsif parseString.include? "QTY"
      #     additional_watt_hour = parseString[8...parseString.length].to_f
      #     new_watt_hour = watt_hour + additional_watt_hour
      #     watts = (new_watt_hour - watt_hour)*4*1000 #convert to mW
      #     watt_hour += additional_watt_hour
      #     watt_hour = watt_hour.round(3)
      #   end
      # end
    end
    infile.close
  end
end
