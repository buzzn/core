# ActiveRecord::Base.logger = Logger.new(STDOUT)
require_relative "../lib/beekeeper/init"

def get_zählwerk(sea)
  vertragsnummer, nummernzusatz = sea.split("/")
  # The meter of a SEA often has two registers. We need the one that measures the generated energy,
  # which can be identifies by the "2.8.0"-obis.
  output_obis = "1-1:2.8.0"
  Beekeeper::Minipool::MsbZählwerkDaten.find_by(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz, obis: output_obis)
end

Beekeeper::Minipool::MinipoolObjekte.all.each do |objekt|
  puts
  puts objekt.minipool_name
  puts "-" * 80
  (1..3).each do |i|
    field = "sea_#{i}_buzznid"
    sea   = objekt.send(field)
    next if sea.empty?
    puts
    puts "Stromerzeugungsanlage #{sea}:"
    puts "- sea_#{i}_energieträger:             #{objekt.send("sea_#{i}_energieträger")}"
    zählwerk = get_zählwerk(sea)
    if zählwerk
      puts "- zählwerk.kennzeichnung:          #{zählwerk.kennzeichnung}"
      puts "- zählwerk.msb_gerät.adresszusatz: #{zählwerk.msb_gerät.adresszusatz}"
    else
      puts "- no zählwerk!!!"
    end
  end
end
