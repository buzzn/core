Fabricator :register do
  low_load_ability    false
  digits_before_comma 6
  decimal_digits      3
  virtual             false
end

Fabricator :in_register, from: :register do
  obis  "1-0:1.8.0"
  label "consumption"
end

Fabricator :out_register, from: :register do
  obis  "1-0:2.8.0"
  label "production"
end

Fabricator :in_register_with_metering_point, from: :register do
  obis  "1-0:1.8.0"
  label "consumption"
  metering_point {Fabricate(:metering_point)}
end

Fabricator :out_register_with_metering_point, from: :register do
  obis  "1-0:2.8.0"
  label "production"
  metering_point {Fabricate(:out_metering_point_with_manager)}
end

Fabricator :out_register_with_metering_point_readable_by_world, from: :register do
  obis  "1-0:2.8.0"
  label "production"
  metering_point {Fabricate(:out_metering_point_readable_by_world)}
end


