# namespace :slp do
#   desc 'This adds slp values to the db'
#   task :import_h0 => :environment do
#     puts "Creating SLP"
#     infile = File.new("#{Rails.root}/db/slp/MSCONS_TL_9907399000009_9905229000008_20130920_40010113207322_RH0.txt", "r")
#     all_lines = infile.readline
#     infile.close
#     watt_hour = 0.0
#     while true do
#       posOfSeperator = all_lines.index("'")
#       if posOfSeperator == nil
#         break
#       else
#         parseString = all_lines[0...posOfSeperator]
#         all_lines = all_lines[(posOfSeperator + 1)..all_lines.length]
#         if parseString.include? "DTM+163"
#           remString = parseString[8..parseString.length]
#           dateString = remString[0..3] + "-" + remString[4..5] + "-" + remString[6..7] + " " + remString[8..9] + ":" + remString[10..11]
#           if Reading.where(source: "slp").last.timestamp.year.to_s == dateString[0..3]
#             puts "SLP for "dateString[0..3] + " already available."
#             break
#           end
#           Reading.create(
#             timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
#             watt_hour: watt_hour,
#             source: "slp"
#           )
#         elsif parseString.include? "QTY"
#           watt_hour += parseString[8...parseString.length].to_f
#           watt_hour = watt_hour.round(3)
#         end
#       end
#     end
#   end
# end