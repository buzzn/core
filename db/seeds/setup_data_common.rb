puts "seeds: loading common setup data"

FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions
include FactoryGirl::Syntax::Methods

Account::Status.delete_all
[[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']].each do |id, name|
  Account::Status.create!(id: id, name: name)
end

Organization.delete_all
Organization.buzzn = FactoryGirl.create(:organization, :with_address,
                   name: 'Buzzn GmbH',
                   description: 'Purveyor of peoplepower since 2009',
                   slug: 'buzzn',
                   email: 'dev+buzzn@buzzn.net',
                   phone: '089 / 32 16 8',
                   website: 'www.buzzn.net'
)
Organization.discovergy = FactoryGirl.create(:organization, :with_address,
                   name: 'Discovergy',
                   description: 'MPO of EasyMeters',
                   slug: 'discovergy',
                   website: 'https://discovergy.com'
)
Organization.germany = FactoryGirl.create(:organization, :with_address,
                   name: 'Germany Energy Mix',
                   description: 'used for energy mix \'Germany\'',
                   slug: 'germany',
                   energy_classifications: [ FactoryGirl.create(:energy_classification, :germany) ]
)
