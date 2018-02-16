SampleData.market_locations = OpenStruct.new

def create_market_location(name)
  MarketLocation.create!(name: name, group: SampleData.localpools.people_power)
end

(1..10).each do |i|
  SampleData.market_locations.send("wohnung_#{i}=", create_market_location("Wohnung #{i}"))
end

SampleData.market_locations.common_consumption = create_market_location('Allgemeinstrom')
