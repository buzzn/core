# coding: utf-8
describe "Address Model" do

  let(:admin) do
    admin = Fabricate(:user)
    admin.add_role(:admin, nil)
    admin.friends << Fabricate(:user)
    admin
  end

  let(:mp_manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, urban)
    manager.friends << Fabricate(:user)
    manager
  end

  let(:orga_manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, organization)
    manager
  end

  let(:karin) { Fabricate(:mp_pv_karin) }
  let(:urban) { Fabricate(:mp_urbanstr88) }

  let(:organization) do
    Fabricate(:transmission_system_operator_with_address)
  end

  let(:contracting_party) do
    cp = Fabricate(:contracting_party, address: Fabricate(:address, street_name: 'Sachsenstr.', street_number: '8', zip: 86916, city: 'Kaufering', state: 'Bayern'), user: Fabricate(:user), organization: organization)
  end

  before do
    # get all addresses in place
    karin
    urban
    organization
    contracting_party
  end

  it 'restricts readable_by for anonymous users', :retry => 3 do
    expect(Address.readable_by(nil)).to eq [organization.address]
  end

  it 'restricts readable_by for managers of metering_points', :retry => 3 do
    expect(Address.readable_by(mp_manager)).to eq [urban.address, organization.address]
    expect(Address.readable_by(admin.friends.first)).to eq [organization.address]
  end

  it 'restricts readable_by for friends of a manager of a metering_points', :retry => 3 do
    expect(Address.readable_by(mp_manager.friends.first)).to match_array [urban.address, organization.address]

    [:members, :community].each do |readable|
      urban.update! readable: readable
      expect(Address.readable_by(mp_manager.friends.first)).to eq [organization.address]
      expect(Address.readable_by(admin.friends.first)).to eq [organization.address]
    end
  end

  it 'restricts readable_by for contracting_party users', :retry => 3 do
    expect(Address.readable_by(contracting_party.user)).to match_array [contracting_party.address, organization.address]
  end

  it 'restricts readable_by for contracting_party address to organization manager', :retry => 3 do
    expect(Address.readable_by(orga_manager)).to match_array [contracting_party.address, organization.address]
  end

  it 'does not restrict readable_by for admins', :retry => 3 do
    expect(Address.readable_by(admin)).to match_array Address.all
  end

end
