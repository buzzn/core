def create_market_location(name)
  FactoryGirl.create(:market_location, :with_market_location_id, name: name, group: SampleData.localpools.people_power)
end

#
# More registers (without powertakers & contracts)
#
SampleData.registers = OpenStruct.new(
  ecar: create(:register, :input, label: Register::Base.labels[:consumption_common],
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    devices: [build(:device, :ecar, commissioning: '2017-04-10', register: nil)],
    market_location: create_market_location('Ladestation eAuto')
              ),
  bhkw: create(:register, :production_bhkw,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    devices: [build(:device, :bhkw, commissioning: '1995-01-01', register: nil)],
    market_location: create_market_location('Produktion BHKW')
              ),
  pv: create(:register, :production_pv,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    devices: [build(:device, :pv, commissioning: '2017-04-10', register: nil)],
    market_location: create_market_location('Produktion PV')
            ),
  water: create(:register, :production_water,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    market_location: create_market_location('Produktion Wasserkraft')
               ),
  # This virtual register sums up the consumption of all powertakers supplied by buzzn.
  # That's why the formula parts subtract powertaker 6's register, since he is supplied by a third party.

  #
  # FIXME creating the following registers fails due to a DB constraint error:
  # PG::NotNullViolation: ERROR:  null value in column "meter_id" violates not-null constraint
  # I wasn't able to debug it or understand why this doesn't happen on the real meters above.
  # Maybe we won't be using the virtual registers like this any more soon, so I don't debug the creation any further.
  #
  # grid_consumption_corrected: create(:register, :virtual_input,
  #   meter: build(:meter, :virtual, group: SampleData.localpools.people_power, registers: []),
  #   label: Register::Base.labels[:grid_consumption_corrected],
  #   formula_parts: [
  #     build(:formula_part, :plus,  operand: SampleData.meters.grid.registers.input.first, register: nil),
  #     build(:formula_part, :minus, operand: SampleData.contracts.pt6.register, register: nil)
  #   ]
  # ),
  # grid_feeding_corrected: create(:register, :virtual_output,
  #   meter: build(:meter, :virtual, group: SampleData.localpools.people_power),
  #   label: Register::Base.labels[:grid_feeding_corrected],
  # )
)
