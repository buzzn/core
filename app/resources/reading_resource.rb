class ReadingResource < ApplicationResource
  attributes  :energy_a_milliwatt_hour,
              :energy_b_milliwatt_hour,
              :power_a_milliwatt,
              :power_b_milliwatt,
              :timestamp,
              :meter_id
end
