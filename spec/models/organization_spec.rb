# coding: utf-8
describe "Organization Model" do

  entity(:organization) { Fabricate(:hell_und_warm) }

  entity!(:organizations) do
    [ Fabricate(:metering_point_operator),
      Fabricate(:electricity_supplier) ]
  end
    
  it 'filters organization' do
    [organization.name, organization.mode, organization.email,
     organization.description, organization.website, organization.address.state,
     organization.address.city, organization.address.street_name].each do |val|

      len = (val.size * 3)/4
      [val, val.upcase, val.downcase, val[0..len], val[-(len+1)..-1]].each do |value|
        organizations = Organization.filter(value)
        expect(organizations.detect{|o| o == organization}).to eq organization
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    organizations = Organization.filter('Der Clown ist müde und geht nach Hause.')
    expect(organizations.size).to eq 0
  end


  it 'filters organization with no params', :retry => 3 do
    organizations = Organization.filter(nil)
    expect(organizations.size).to eq Organization.count
  end
end
