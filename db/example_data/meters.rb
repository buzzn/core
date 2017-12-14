SampleData.meters = OpenStruct.new(
  # the connection to the public grid, two-way register
  grid: create(:meter, :real, :two_way,
    group: SampleData.localpools.people_power,
    registers: [
      create(:register, :grid_output,
        readings: [
          build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
          build(:reading, :regular, date: '2016-12-31', raw_value: 12_000_000, register: nil)
        ]
      ),
      create(:register, :grid_input,
        readings: [
          build(:reading, :setup, date: '2016-01-01', raw_value: 2_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
          build(:reading, :regular, date: '2016-12-31', raw_value: 66_000_000, register: nil)
        ]
      )
    ]
  ),
  discovergy: Broker::Discovergy.create(meter: Meter::Discovergy.create(group: SampleData.localpools.people_power, product_serialnumber: '00000106')).meter
)
