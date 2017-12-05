#
# More registers (without powertakers & contracts)
#
SampleData.registers = OpenStruct.new(
  ecar: create(:register, :input, name: 'Ladestation eAuto', label: Register::Base.labels[:other],
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    devices: [ build(:device, :ecar, commissioning: '2017-04-10', register: nil) ]
  ),
  bhkw: create(:register, :production_bhkw,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    devices: [ build(:device, :bhkw, commissioning: '1995-01-01', register: nil) ]
  ),
  pv: create(:register, :production_pv,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power),
    devices: [ build(:device, :pv, commissioning: '2017-04-10', register: nil) ]
  ),
  water: create(:register, :production_water,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)
  ),
  # This virtual register sums up the consumption of all powertakers supplied by buzzn.
  # That's why the formula parts subtract powertaker 6's register, since he is supplied by a third party.

  # Temporarily disabled because they fail
  # grid_consumption_corrected: create(:register, :virtual_input,
  #   meter: build(:meter, :virtual, group: SampleData.localpools.people_power),
  #   label: Register::Base.labels[:grid_consumption_corrected],
  #   name: "ÜGZ Bezug korrigiert",
  #   formula_parts: [
  #     build(:formula_part, :plus,  operand: SampleData.meters.grid.registers.input.first, register: nil),
  #     build(:formula_part, :minus, operand: SampleData.contracts.pt6.register, register: nil)
  #   ]
  # ),
  # grid_feeding_corrected: create(:register, :virtual_output,
  #   meter: build(:meter, :virtual, group: SampleData.localpools.people_power),
  #   label: Register::Base.labels[:grid_feeding_corrected],
  #   name: "ÜGZ Einspeisung korrigiert"
  # )
)
