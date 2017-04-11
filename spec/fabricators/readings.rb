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
