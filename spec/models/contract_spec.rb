# coding: utf-8
describe "Contract Model" do

  entity(:register) { Fabricate(:output_meter).output_register }
  entity(:input_register) { Fabricate(:input_meter).input_register }
  entity(:admin) { Fabricate(:admin) }

  entity(:user_with_register) do
    user = Fabricate(:user)
    user.add_role(:manager, register)
    user
  end

  entity(:manager_group) { Fabricate(:tribe)}

  entity(:member_group) { Fabricate(:localpool)}

  entity!(:contracts) do
    c1 = Fabricate(:metering_point_operator_contract, customer: user_with_register.person, localpool: member_group)
    c2 = Fabricate(:power_giver_contract, register: register)
    manager_group.registers << c2.register
    [c1, c2]
  end

  entity(:address) { Fabricate(:address_limmat_5) }

  entity!(:contract) do
    c = Fabricate(:mpoc_stefan)
    c.customer.update(address: address)
    c
  end

  entity(:localpool) { Fabricate(:localpool) }

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

  # TODO fix filtering or remove it
  xit 'filters contract' do
    [contract.address.state,
     contract.address.city, contract.address.street_name
    ].each do |val|

      [val, val.upcase, val.downcase, val[0..40], val[-40..-1]].each do |value|
        contracts = Contract.filter(value)
        expect(contracts).to includes contract
      end
    end
  end


  xit 'filters can not find anything' do
    contracts = Contract::Base.filter('Der Clown ist müde und geht nach Hause.')
binding.pry
    expect(contracts.size).to eq 0
  end


  xit 'filters contract with no params' do
    contracts = Contract::Base.filter(nil)
    expect(contracts.size).to eq Contract::Base.count
  end


  it 'does not create contract with same contract_number_addition' do
    contract = Fabricate(:localpool_power_taker_contract, contract_number: 123456, contract_number_addition: 1)
    expect{ Fabricate(:localpool_power_taker_contract, contract_number: 123456, contract_number_addition: 1) }.to raise_error ActiveRecord::RecordInvalid
  end
end
