Fabricator :reading do
  timestamp { Time.at(sequence(:timestamp, 1451602802))  }
  energy_a_milliwatt_hour { sequence(:energy_a_milliwatt_hour, 271000000) }
  energy_b_milliwatt_hour { sequence(:energy_b_milliwatt_hour, 50) }
  power_milliwatt { 900*1000 }
end

Fabricator :reading_with_metering_point, from: :reading do
  metering_point_id { Fabricate(:metering_point).id  }
end

Fabricator :reading_with_metering_point_and_manager, from: :reading do
  metering_point_id { Fabricate(:metering_point_with_manager).id  }
end
