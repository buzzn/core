puts "seeds: loading common setup data"

Account::Status.delete_all
[[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']].each do |id, name|
  Account::Status.create!(id: id, name: name)
end

Organization.delete_all
Organization.buzzn = Organization.create!(
  name: 'Buzzn GmbH',
  description: 'Purveyor of peoplepower since 2009',
  slug: 'buzzn',
  email: 'dev+buzzn@buzzn.net',
  phone: '089 / 32 16 8',
  website: 'www.buzzn.net',
  # energy_classifications: [ FactoryGirl.build(:energy_classification, :buzzn) ],
  # FIXME !
  # address: FactoryGirl.build(:address),
  # FIXME rename to contact person and add real contact
  # contact: FactoryGirl.build(:person)
)
Organization.buzzn.market_functions << OrganizationMarketFunction.new(
  function: :electricity_supplier,
  market_partner_id: "9905229000008",
  edifact_email: "justus@buzzn.net",
  # FIXME: implement fallback to organization when the following two fields are empty.
  address: Organization.buzzn.address,
  contact_person: Organization.buzzn.contact
)

# TODO
# Organization.discovergy = Organization.create!(
#   name: 'Discovergy',
#   description: 'MPO of EasyMeters',
#   slug: 'discovergy',
#   website: 'https://discovergy.com'
# )
# Organization.germany = Organization.create!(
#   name: 'Germany Energy Mix',
#   description: 'used for energy mix \'Germany\'',
#   slug: 'germany',
#   energy_classifications: [ FactoryGirl.create(:energy_classification, :germany) ]
# )
