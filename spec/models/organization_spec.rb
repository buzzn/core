# coding: utf-8
describe "Organization Model" do

  entity(:organization) { Fabricate(:hell_und_warm) }

  entity!(:organizations) do
    [ Fabricate(:metering_point_operator),
      Fabricate(:electricity_supplier) ]
  end

  it 'filters organization' do
    [organization.name, organization.mode, organization.email,
     organization.description, organization.website, organization.address.zip,
     organization.address.city, organization.address.street].each do |val|

      len = (val.size * 3)/4
      [val, val.upcase, val.downcase, val[0..len], val[-(len+1)..-1]].each do |value|
        organizations = Organization.filter(value)
        expect(organizations).to include organization
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

  describe "market functions", :focus do
    context "when org has a market function" do
      before { organization.market_functions.create(function_name: :power_giver, market_partner_id: "42") }
      it "is returned correctly" do
        expect(organization.market_functions.size).to eq(1)
        expect(organization.market_functions.first.market_partner_id).to eq("42")
      end
      it "can be accessed through the method #in_market_function" do
        expect(organization.in_market_function(:power_giver).market_partner_id).to eq("42")
      end
    end
  end
end
