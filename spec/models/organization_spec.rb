# coding: utf-8
describe "Organization Model" do

  it 'filters organization', :retry => 3 do
    organization = Fabricate(:transmission_system_operator_with_address)
    2.times { Fabricate(:metering_point_operator) }

    [organization.name, organization.mode, organization.email,
     organization.description, organization.website, organization.address.state,
     organization.address.city, organization.address.street_name].each do |val|

      len = (val.size * 3)/4
      [val, val.upcase, val.downcase, val[0..len], val[-(len+1)..-1]].each do |value|
        organizations = Organization.filter(value)
        expect(organizations.first).to eq organization
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:electricity_supplier)
    organizations = Organization.filter('Der Clown ist müde und geht nach Hause.')
    expect(organizations.size).to eq 0
  end


  it 'filters organization with no params' do
    5.times { Fabricate(:metering_service_provider) }

    organizations = Organization.filter(nil)
    expect(organizations.size).to eq Organization.count
  end
end
