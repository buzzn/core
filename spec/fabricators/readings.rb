Fabricator :reading do
  timestamp { Time.at(sequence(:timestamp, 1451602802))  }
  energy_a_milliwatt_hour { sequence(:energy_a_milliwatt_hour, 271000000) }
  power_a_milliwatt { 900*1000 }
end


['input_register', 'output_register'].each do |register|

  Fabricator "reading_with_easy_meter_q3d_and_#{register}", from: :reading do
    register_id {
      Fabricate("easy_meter_q3d_with_#{register}").send(register).id
    }
  end

  Fabricator "reading_with_easy_meter_q3d_with_#{register}_and_manager", from: :reading do
    register_id {
      binding.pry
      Fabricate("easy_meter_q3d_with_#{register}_and_manager").send(register).id
    }
  end

end
