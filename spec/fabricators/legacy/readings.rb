Fabricator :reading, class_name: Reading::Continuous do
  timestamp { Time.at(sequence(:timestamp, 1451602802))  }
  energy_milliwatt_hour { sequence(:energy_milliwatt_hour, 271000000) }
  power_milliwatt { 900*1000 }
  quality { Reading::Continuous::READ_OUT }
  source { Reading::Continuous::BUZZN_SYSTEMS }
  reason { Reading::Continuous::REGULAR_READING }
  meter_serialnumber { '12346578' }
  register_id { sequence(:register_id, 54321654987) }
end

Fabricator :single_reading, class_name: Reading::Single do
  i = Kernel.rand(2000)
  date { i += 1; Date.today - i.days }
  raw_value { rand(2173123)  }
  value { sequence(:value, 27100) }
  unit { Reading::Single::WH }
  quality { Reading::Single::READ_OUT }
  source { Reading::Single::MANUAL }
  read_by { Reading::Single::BUZZN }
  reason { Reading::Single::REGULAR_READING }
  register { Fabricate(:meter).registers.first }
  status { Reading::Single::Z86 }
end
