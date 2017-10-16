describe "Organization Model" do

  describe "predefined organizations" do
    before             { create(:organization, name: 'buzzn GmbH', slug: 'buzzn-energy') }
    let(:buzzn_energy) { Organization.find_by(slug: 'buzzn-energy') }
    after(:each)       { Organization.destroy_all } # FIXME clean DB before each test even when running with rspec

    it "can be found by constant" do
      expect(Organization::BUZZN_ENERGY).to eq(buzzn_energy.name)
    end

    it "can be found by method" do
      expect(Organization.buzzn_energy).to eq(buzzn_energy)
    end

    describe "predicate method" do
      it "returns true when org is in symbol" do
        expect(buzzn_energy).to be_buzzn_energy
      end
      it "returns false when org is not in symbol" do
        expect(create(:organization)).not_to be_buzzn_energy
      end
    end
  end

  describe "filtering" do
    let(:org_to_find)          { create(:organization, :with_address) }
    let!(:other_organizations) { create_list(:organization, 2, :with_address) }

    it 'filters organization' do
      [org_to_find.name, org_to_find.email,
       org_to_find.description, org_to_find.website, org_to_find.address.zip,
       org_to_find.address.city, org_to_find.address.street].each do |value|

        # FIXME: clarify what's going on here.
        length = (value.size * 3)/4
        searchable_values = [
          value,
          value.upcase,
          value.downcase,
          value[0..length],
          # FIXME: clarify what's going on here.
          value[-(length+1)..-1]
        ]
        searchable_values.each do |search_string|
          found_organizations = Organization.filter(search_string)
          expect(found_organizations).to include org_to_find
        end
      end
    end

    it 'can not find anything', :retry => 3 do
      organizations = Organization.filter('Der Clown ist müde und geht nach Hause.')
      expect(organizations).to be_empty
    end


    it 'filters organization with no params', :retry => 3 do
      other_organizations = Organization.filter(nil)
      expect(other_organizations.size).to eq Organization.count
    end
  end

  describe "market functions" do
    context "when org has a market function" do
      let!(:record)      { create(:organization_market_function, function: :power_giver) }
      let(:organization) { record.organization }

      it "is returned correctly" do
        expect(organization.market_functions.size).to eq(1)
        expect(organization.market_functions.first).to eq(record)
      end

      it "can be accessed through the method #in_market_function" do
        expect(organization.in_market_function(:power_giver)).to eq(record)
      end
    end
  end
end
