def update_register(register, name)
  ml = FactoryGirl.create(:market_location, register: register)
  register.meta.update(name: name)
  register
end

#
# More registers (without powertakers & contracts)
#
SampleData.registers = OpenStruct.new(
  bhkw: update_register(create(:register, :production_bhkw,
                               meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)), 'Produktion BHKW'),
  pv: update_register(create(:register, :production_pv,
                             meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)), 'Produktion PV'),
  water: update_register(create(:register, :production_water,
                                meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)), 'Produktion Wasserkraft')
)
