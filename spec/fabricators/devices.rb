Fabricator(:new_device, class_name: 'Device') do
#  name        { sequence { |i| "Localpool #{i}" } }
#  description { |attrs| "#{attrs[:name]} description" }
end
