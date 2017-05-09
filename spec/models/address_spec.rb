# coding: utf-8
describe Address do

  entity(:admin) do
    admin = Fabricate(:admin)
    admin.friends << Fabricate(:user)
    admin
  end

  entity(:register_manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, urban)
    manager.friends << Fabricate(:user)
    manager
  end

  entity(:organization_manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, organization)
    manager
  end

  entity!(:karin) { Fabricate(:register_pv_karin, meter: Fabricate(:meter)) }
  entity!(:urban) { Fabricate(:register_urbanstr88, meter: Fabricate(:meter)) }
  entity!(:organization) { Fabricate(:hell_und_warm) }

  entity!(:contracting_party) do
    Fabricate(:user, address: Fabricate(:address, street_name: 'Sachsenstr.', street_number: '8', zip: 86916, city: 'Kaufering', state: 'Bayern'))
  end

  it 'restricts readable_by for anonymous users' do
    expect(Address.readable_by(nil)).to eq [organization.address]
  end

  it 'restricts readable_by for managers of registers' do
    expect(Address.readable_by(register_manager)).to eq [urban.address, organization.address, contracting_party.address]
    expect(Address.readable_by(admin.friends.first)).to eq [organization.address, contracting_party.address]
  end

  it 'restricts readable_by for friends of a manager of a registers' do
    expect(Address.readable_by(register_manager.friends.first)).to match_array [urban.address, organization.address, contracting_party.address]

    [:members, :community].each do |readable|
      urban.update! readable: readable
      expect(Address.readable_by(register_manager.friends.first)).to eq [organization.address, contracting_party.address]
      expect(Address.readable_by(admin.friends.first)).to eq [organization.address, contracting_party.address]
    end
  end

  # it 'restricts readable_by for contracting_party users', :retry => 3 do
  #   expect(Address.readable_by(contracting_party.user)).to match_array [contracting_party.address, organization.address]
  # end

  it 'restricts readable_by for contracting_party address to organization manager' do
    expect(Address.readable_by(organization_manager)).to match_array [contracting_party.address, organization.address]
  end

  it 'does not restrict readable_by for admins', :retry => 3 do
    expect(Address.readable_by(admin)).to match_array Address.all
  end

end
