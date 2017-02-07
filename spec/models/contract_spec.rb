# coding: utf-8
describe "Contract Model" do

  let(:register) { Fabricate(:output_meter).output_register }

  let(:user_with_register) do
    user = Fabricate(:user)
    user.add_role(:manager, register)
    Fabricate(:contracting_party, user: user)
    user
  end

  let(:manager_tribe) {Fabricate(:tribe)}

  let(:manager_of_tribe) do
    user = Fabricate(:user)
    user.add_role(:manager, manager_tribe)
    user
  end

  let(:member_localpool) {Fabricate(:localpool)}

  let(:member_of_localpool) do
    user = Fabricate(:user)
    user.add_role(:member, member_localpool)
    user
  end

  let(:manager_of_organization) do
    user = Fabricate(:user)
    contracts.first.customer = user.contracting_parties.first
    user.add_role(:manager, contracts.last.customer.organization)
    user
  end

  let(:member_of_organization) do
    user = Fabricate(:user)
    user.add_role(:member, contracts.last.customer.organization)
    user
  end

  let(:contracts) do
    c1 = Fabricate(:metering_point_operator_contract, customer: user_with_register, localpool: member_localpool)
    c2 = Fabricate(:power_giver_contract, register: register)
    manager_tribe.registers << c2.register
    [c1, c2]
  end

  it 'filters contract', :retry => 3 do
    contract = Fabricate(:mpoc_stefan)

    if user_with_register.is_a? ContractingParty
      #TODO bring filtering back
      raise 'fix me'
    end

    #contract.address = Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern')
    Fabricate(:mpoc_karin)

    [#contract.mode,
     #contract.signing_user,
     #contract.username, contract.address.state,
     #contract.address.city, contract.address.street_name
    ].each do |val|

      [val, val.upcase, val.downcase, val[0..40], val[-40..-1]].each do |value|
        contracts = Contract.filter(value)
        expect(contracts.sort{|x,y| x.username <=> y.username}.last).to eq contract
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    Fabricate(:mpoc_stefan)
    contracts = Contract.filter('Der Clown ist müde und geht nach Hause.')

    if user_with_register.is_a? ContractingParty
      #TODO bring filtering back
      raise 'fix me'
    end

    #expect(contracts.size).to eq 0
  end


  it 'filters contract with no params', :retry => 3 do
    Fabricate(:mpoc_stefan)
    Fabricate(:mpoc_karin)

    contracts = Contract.filter(nil)
    expect(contracts.size).to eq 2
  end

  it 'selects no contracts for anonymous user' do
    contracts # create contracts
    expect(Contract.readable_by(nil)).to eq []
  end

  it 'selects all contracts by admin' do
    contracts # create contracts
    expect(Contract.readable_by(Fabricate(:admin))).to eq contracts
  end

  it 'selects contracts of register manager' do
    contracts # create contracts
    expect(Contract.readable_by(user_with_register)).to eq [contracts.last]
  end

  it 'selects contracts of organization manager but not organization member' do
    contracts # create contracts
    #TODO: change readable by in contract model to get this working
    expect(Contract::Base.readable_by(manager_of_organization)).to eq [contracts.last]
    expect(Contract::Base.readable_by(member_of_organization)).to eq []
  end

  it 'selects contracts of group manager but not group member' do
    contracts # create contracts
    if user_with_register.is_a? ContractingParty
      #TODO: change readable by in contract model to get this working
      expect(Contract.readable_by(manager_of_tribe)).to eq [contracts.last]
    end
    expect(Contract.readable_by(member_of_localpool)).to eq []
  end
end
