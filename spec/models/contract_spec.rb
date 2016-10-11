# coding: utf-8
describe "Contract Model" do

  let(:user_with_metering_point) { Fabricate(:user_with_metering_point) }
  let(:manager_group) {Fabricate(:group)}
  let(:manager_of_group) do
    user = Fabricate(:user)
    user.add_role(:manager, manager_group)
    user
  end
  let(:member_group) {Fabricate(:group)}
  let(:member_of_group) do
    user = Fabricate(:user)
    user.add_role(:member, member_group)
    user
  end
  let(:manager_of_organization) do
    user = Fabricate(:user)
    user.add_role(:manager, contracts.last.organization)
    user
  end
  let(:member_of_organization) do
    user = Fabricate(:user)
    user.add_role(:member, contracts.last.organization)
    user
  end

  let(:contracts) do
    c1 = Fabricate(:metering_point_operator_contract)
    c1.metering_point = user_with_metering_point.roles.first.resource
    c1.group = member_group
    c1.save!
    c2 = Fabricate(:electricity_supplier_contract)
    c2.group = manager_group
    c2.save!
    [c1, c2]
  end

  it 'filters contract', :retry => 3 do
    Fabricate(:discovergy)
    contract = Fabricate(:mpoc_stefan)
    contract.address = Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern')
    Fabricate(:mpoc_karin)

    [contract.tariff, contract.mode, contract.signing_user,
     contract.username, contract.address.state,
     contract.address.city, contract.address.street_name].each do |val|

      [val, val.upcase, val.downcase, val[0..40], val[-40..-1]].each do |value|
        contracts = Contract.filter(value)
        expect(contracts.sort{|x,y| x.username <=> y.username}.last).to eq contract
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    Fabricate(:discovergy)
    Fabricate(:mpoc_justus)
    contracts = Contract.filter('Der Clown ist müde und geht nach Hause.')
    expect(contracts.size).to eq 0
  end


  it 'filters contract with no params', :retry => 3 do
    Fabricate(:discovergy)
    Fabricate(:mpoc_stefan)
    Fabricate(:mpoc_karin)

    contracts = Contract.filter(nil)
    expect(contracts.size).to eq 2
  end

  it 'selects no contracts for anonymous user', :retry => 3 do
    contracts # create contracts
    expect(Contract.readable_by(nil)).to eq []
  end

  it 'selects all contracts by admin', :retry => 3 do
    contracts # create contracts
    expect(Contract.readable_by(Fabricate(:admin))).to eq contracts
  end

  it 'selects contracts of metering_point manager', :retry => 3 do
    contracts # create contracts
    expect(Contract.readable_by(user_with_metering_point)).to eq [contracts.first]
  end

  it 'selects contracts of organization manager but not organization member', :retry => 3 do
    contracts # create contracts
    expect(Contract.readable_by(manager_of_organization)).to eq [contracts.last]
    expect(Contract.readable_by(member_of_organization)).to eq []
  end

  it 'selects contracts of group manager but not group member', :retry => 3 do
    contracts # create contracts
    expect(Contract.readable_by(manager_of_group)).to eq [contracts.last]
    expect(Contract.readable_by(member_of_group)).to eq []
  end
end
