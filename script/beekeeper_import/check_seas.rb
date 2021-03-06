# ActiveRecord::Base.logger = Logger.new(STDOUT)
require_relative '../lib/beekeeper/init'

def get_zählwerke(sea)
  vertragsnummer, nummernzusatz = sea.split('/')
  Beekeeper::Minipool::MsbZählwerkDaten.where(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz).order(:obis)
end

Beekeeper::Minipool::MinipoolObjekte.all.order(:minipool_start, :minipool_name).each do |objekt|
  puts
  puts "#{objekt.minipool_name} (start: #{objekt.minipool_start})"
  puts '-' * 80
  (1..3).each do |i| # sea_4_buzznid never contains a SEA, it's abused to pass other info during the import.
    field = "sea_#{i}_buzznid"
    sea   = objekt.send(field)
    next if sea.empty?
    puts
    puts "Stromerzeugungsanlage #{sea}:"
    puts "- sea_#{i}_energieträger:             #{objekt.send("sea_#{i}_energieträger")}"
    get_zählwerke(sea).each do |zählwerk|
      if zählwerk
        puts "- zählwerk.zählwerkID:             #{zählwerk.zählwerkID}"
        puts "- zählwerk.obis:                   #{zählwerk.obis}"
        puts "- zählwerk.kennzeichnung:          #{zählwerk.kennzeichnung}"
        puts "- zählwerk.msb_gerät.adresszusatz: #{zählwerk.msb_gerät.adresszusatz}"
      else
        puts '- no zählwerk!!!'
      end
    end
  end
end
