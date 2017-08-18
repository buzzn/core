Fabricator :reading do
  timestamp { Time.at(sequence(:timestamp, 1451602802))  }
  energy_milliwatt_hour { sequence(:energy_milliwatt_hour, 271000000) }
  power_milliwatt { 900*1000 }
  quality { Reading::READ_OUT }
  source { Reading::BUZZN_SYSTEMS }
  reason { Reading::REGULAR_READING }
  meter_serialnumber { '12346578' }
  register_id { sequence(:register_id, 54321654987) }
end

Fabricator :single_reading do
  i = Kernel.rand(2000)
  date { i += 1; Date.today - i.days }
  raw_value { rand(2173123)  }
  value { sequence(:value, 27100) }
  unit { 'Wh' }
  quality { SingleReading::READ_OUT }
  source { SingleReading::BUZZN_SYSTEMS }
  reason { SingleReading::REGULAR_READING }
  register { Fabricate(:meter).registers.first }
end
