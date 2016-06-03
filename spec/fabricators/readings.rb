Fabricator :reading do
  timestamp { Time.at(sequence(:timestamp, 1451602802))  }
  energy_a_milliwatt_hour { sequence(:energy_a_milliwatt_hour, 271000000) }
  power_a_milliwatt { 900*1000 }
end

Fabricator :reading_with_easy_meter_q3d_and_metering_point, from: :reading do
  meter_id { Fabricate(:easy_meter_q3d_with_metering_point).id  }
end

Fabricator :reading_with_easy_meter_q3d_and_manager, from: :reading do
  meter_id { Fabricate(:easy_meter_q3d_with_manager).id  }
end
