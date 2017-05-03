# coding: utf-8
describe "Contract Model" do

  let(:register) { Fabricate(:output_meter).output_register }
  let(:input_register) { Fabricate(:input_meter).input_register }
  let(:admin) { Fabricate(:admin) }
  let(:user_with_register) do
    user = Fabricate(:user)
    user.add_role(:manager, register)
    user
  end
  let(:manager_group) {Fabricate(:tribe)}
  let(:manager_of_group) do
    user = Fabricate(:user)
    user.add_role(:manager, manager_group)
    user
  end
  let(:member_group) {Fabricate(:localpool)}
  let(:member_of_group) do
    user = Fabricate(:user)
    user.add_role(:member, member_group)
    user
  end
  let(:manager_of_organization) do
    user = Fabricate(:user)
    contracts.first.customer = user
    user.add_role(:manager, contracts.last.customer)
    user
  end
  let(:member_of_organization) do
    user = Fabricate(:user)
    user.add_role(:member, contracts.last.customer)
    user
  end

  let(:contracts) do
    c1 = Fabricate(:metering_point_operator_contract, customer: user_with_register, localpool: member_group)
    c2 = Fabricate(:power_giver_contract, register: register)
    manager_group.registers << c2.register
    [c1, c2]
  end

  let(:localpool) { Fabricate(:localpool) }

  it 'loads contract via where with the right type' do
    Fabricate(:metering_point_operator_contract, localpool: localpool)
    Fabricate(:localpool_processing_contract, localpool: localpool)
    input_register.group = localpool
    Fabricate(:localpool_power_taker_contract, register: input_register)
    Fabricate(:power_taker_contract_move_in)
    Fabricate(:power_giver_contract)

    types = [Contract::PowerGiver, Contract::PowerTaker,Contract::MeteringPointOperator, Contract::LocalpoolProcessing, Contract::LocalpoolPowerTaker]
    types.each do |type|
      type.where(nil).each do |c|
        expect(c.class).to eq type
        (types - [type]).each do |t|
          expect(t.where(id: c.id)).to eq []
        end
      end
    end

    expect(localpool.localpool_processing_contract.class).to eq Contract::LocalpoolProcessing
    expect(localpool.metering_point_operator_contract.class).to eq Contract::MeteringPointOperator
  end

  xit 'filters contract', :retry => 3 do
    contract = Fabricate(:mpoc_stefan)

    contract.customer.address = Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern')
    Fabricate(:mpoc_karin)

    [contract.address.state,
     contract.address.city, contract.address.street_name
    ].each do |val|

      [val, val.upcase, val.downcase, val[0..40], val[-40..-1]].each do |value|
        contracts = Contract.filter(value)
        expect(contracts.sort{|x,y| x.username <=> y.username}.last).to eq contract
      end
    end
  end


  xit 'filters can not find anything' do
    Fabricate(:mpoc_stefan)
    contracts = Contract::Base.filter('Der Clown ist müde und geht nach Hause.')

    expect(contracts.size).to eq 0
  end


  it 'filters contract with no params' do
    Fabricate(:mpoc_stefan)
    Fabricate(:mpoc_karin)

    contracts = Contract::Base.filter(nil)
    expect(contracts.size).to eq 2
  end

  it 'selects no contracts for anonymous user' do
    contracts # create contracts
    expect(Contract::Base.readable_by(nil)).to eq []
  end

  it 'selects all contracts by admin' do
    contracts # create contracts
    expect(Contract::Base.readable_by(admin)).to match_array contracts
  end

  it 'selects contracts of register manager' do
    contracts # create contracts
    expect(Contract::Base.readable_by(user_with_register)).to eq contracts
  end

  xit 'selects contracts of organization manager but not organization member' do
    contracts # create contracts
    if user_with_register.is_a? ContractingParty
      #TODO: change readable by in contract model to get this working

      expect(Contract.readable_by(manager_of_organization)).to eq [contracts.last]
      expect(Contract.readable_by(member_of_organization)).to eq []
    end
  end

  xit 'selects contracts of group manager but not group member' do
    contracts # create contracts
    #TODO: change readable by in contract model to get this working
    expect(Contract::Base.readable_by(manager_of_tribe)).to eq [contracts.last]
    expect(Contract::Base.readable_by(member_of_localpool)).to eq []
  end

  it 'does not create contract with same contract_number_addition' do
    contract = Fabricate(:localpool_power_taker_contract, contract_number: 123456, contract_number_addition: 1)
    expect{ Fabricate(:localpool_power_taker_contract, contract_number: 123456, contract_number_addition: 1) }.to raise_error ActiveRecord::RecordInvalid
  end
end
