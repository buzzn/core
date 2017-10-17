puts "seeds: loading common setup data"

Account::Status.delete_all
[[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']].each do |id, name|
  Account::Status.create!(id: id, name: name)
end

Organization.delete_all
FactoryGirl.create(:organization, :metering_point_operator,
                   name: 'Discovergy',
                   description: 'MPO of EasyMeters',
                   slug: 'discovergy',
                   website: 'https://discovergy.com'
)
