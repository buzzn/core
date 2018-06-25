def create_market_location(name)
  FactoryGirl.create(:market_location, :with_market_location_id, name: name, group: SampleData.localpools.people_power)
end

#
# More registers (without powertakers & contracts)
#
SampleData.registers = OpenStruct.new(
  bhkw: create(:register, :production_bhkw,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    #devices: [build(:device, :bhkw, commissioning: '1995-01-01', register: nil)],
    market_location: create_market_location('Produktion BHKW')
              ),
  pv: create(:register, :production_pv,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    #devices: [build(:device, :pv, commissioning: '2017-04-10', register: nil)],
    market_location: create_market_location('Produktion PV')
            ),
  water: create(:register, :production_water,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    market_location: create_market_location('Produktion Wasserkraft')
               )
)
