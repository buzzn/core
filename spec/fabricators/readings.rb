Fabricator :reading do
  timestamp { Time.at(sequence(:timestamp, 1451602802))  }
  energy_milliwatt_hour { sequence(:energy_a_milliwatt_hour, 271000000) }
  power_milliwatt { 900*1000 }
end


['input', 'output'].each do |mode|

  Fabricator "reading_with_easy_meter_q3d_and_#{mode}_register", from: :reading do
    register_id {
      Fabricate("easy_meter_q3d_with_#{mode}_register").registers.first.id
    }
  end

  Fabricator "reading_with_easy_meter_q3d_with_#{mode}_register_and_manager", from: :reading do
    register_id {
      Fabricate("easy_meter_q3d_with_#{mode}_register_and_manager").registers.first.id
    }
  end

end
