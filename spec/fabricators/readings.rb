Fabricator :single_reading, class_name: Reading::Single do
  i = Kernel.rand(2000)
  date { i += 1; Date.today - i.days }
  raw_value { rand(2173123) }
  value { sequence(:value, 27100) }
  unit { Reading::Single::WH }
  quality { Reading::Single::READ_OUT }
  source { Reading::Single::MANUAL }
  read_by { Reading::Single::BUZZN }
  reason { Reading::Single::REGULAR_READING }
  register { Fabricate(:meter).registers.first }
  status { Reading::Single::Z86 }
end
