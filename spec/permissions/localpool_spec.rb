# coding: utf-8
describe Group::LocalpoolPermissions do

  def all(user)
    Group::LocalpoolResource.all(user).collect do |l|
      l.object
    end
  end

  entity(:buzzn_operator) do
    user = Fabricate(:user)
    user.add_role(:buzzn_operator, nil)
    user
  end
  entity(:localpool_owner) { Fabricate(:user) }
  entity(:localpool_manager) { Fabricate(:user) }
  entity(:localpool_member) { Fabricate(:user) }
  entity(:localpool_member2) { Fabricate(:user) }
  entity(:localpool_member3) { Fabricate(:user) }
  entity(:localpool_member4) { Fabricate(:user) }
  entity(:user) { Fabricate(:user) }
  let(:anonymous) { nil }

  entity!(:localpool1) do
    pool = Fabricate(:localpool)
    localpool_member.add_role(:localpool_member, pool)
    localpool_member2.add_role(:localpool_member, pool)
    
    pool
  end

  entity!(:localpool2) do
    pool = Fabricate(:localpool)
    localpool_owner.add_role(:localpool_owner, pool)
    localpool_manager.add_role(:localpool_manager, pool)
    localpool_member3.add_role(:localpool_member, pool)
    localpool_member4.add_role(:localpool_member, pool)
    meter = Fabricate(:input_meter)
    # HACK as meter.input_register.group = pool does not work
    meter.input_register.update(group_id: pool.id)
    Fabricate(:localpool_power_taker_contract,
              localpool: pool,
              customer: localpool_member3,
              register: meter.input_register)
    pool
  end
  let(:contract) { localpool2.localpool_power_taker_contracts.first }
  let(:register) { localpool2.registers.real.input.first }

  entity!(:mpoc) { Fabricate(:metering_point_operator_contract,
                             localpool: localpool2) }
  entity!(:lpc) { Fabricate(:localpool_processing_contract,
                            localpool: localpool2) }

  entity!(:price) { Fabricate(:price, localpool: localpool2)}
  entity!(:billing_cycle) { Fabricate(:billing_cycle, localpool: localpool2) }

  it 'create' do
    expect{ Group::LocalpoolResource.create(buzzn_operator, {}) }.to raise_error Buzzn::ValidationError

    expect{ Group::LocalpoolResource.create(localpool_owner, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.create(localpool_manager, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.create(localpool_member, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.create(user, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.create(anonymous, {}) }.to raise_error Buzzn::PermissionDenied
  end

  it 'all' do
    expect(all(buzzn_operator)).to match_array [localpool1, localpool2]
    expect(all(localpool_owner)).to match_array [localpool2]
    expect(all(localpool_manager)).to match_array [localpool2]
    expect(all(localpool_member)).to match_array [localpool1]
    expect(all(user)).to match_array []
    expect(all(anonymous)).to match_array []
  end

  it 'retrieve' do
    expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).object).to eq localpool1
    expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).object).to eq localpool2

    expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect(Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).object).to eq localpool2

    expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect(Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).object).to eq localpool2

    expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool2.id) }.to raise_error Buzzn::PermissionDenied
    expect(Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).object).to eq localpool1

    expect{ Group::LocalpoolResource.retrieve(user, localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect{ Group::LocalpoolResource.retrieve(user, localpool2.id) }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.retrieve(anonymous, localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect{ Group::LocalpoolResource.retrieve(anonymous, localpool2.id) }.to raise_error Buzzn::PermissionDenied    
  end
  
  it 'update' do
    expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).update({}) }.not_to raise_error
    expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).update({}) }.not_to raise_error
    
    expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).update({}) }.not_to raise_error

    expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).update({}) }.not_to raise_error

    expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).update({}) }.to raise_error Buzzn::PermissionDenied
  end
  
  it 'delete' do
    begin
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).delete }.not_to raise_error
      expect(Group::Localpool.where(id: localpool1.id)).to eq []
    ensure
      Group::Localpool.create(localpool1.attributes)
    end

    begin
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).delete }.not_to raise_error
      expect(Group::Localpool.where(id: localpool2.id)).to eq []
    ensure
      Group::Localpool.create(localpool2.attributes)
    end

    expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).delete }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).delete }.to raise_error Buzzn::PermissionDenied

    expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).delete }.to raise_error Buzzn::PermissionDenied
  end

  context 'prices' do

    def prices(user, id)
      Group::LocalpoolResource.retrieve(user, id).prices.collect do |l|
        l.object
      end
    end

    it 'all' do
      expect(prices(buzzn_operator, localpool1.id)).to eq []
      expect(prices(buzzn_operator, localpool2.id)).to match_array localpool2.prices.reload

      expect(prices(localpool_owner, localpool2.id)).to match_array localpool2.prices.reload
      expect(prices(localpool_manager, localpool2.id)).to match_array localpool2.prices.reload
      expect(prices(localpool_member, localpool1.id)).to match_array []

      expect{ prices(localpool_member, localpool2.id) }.to raise_error Buzzn::PermissionDenied
    end

    it 'create' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).create_price }.to raise_error Buzzn::ValidationError
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).create_price }.to raise_error Buzzn::ValidationError

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).create_price }.to raise_error Buzzn::ValidationError
      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).create_price }.to raise_error Buzzn::ValidationError

      expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).create_price }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect{ prices(buzzn_operator, localpool2.id).first.update({}) }.not_to raise_error
    
      expect{ prices(localpool_owner, localpool2.id).first.update({}) }.not_to raise_error

      expect{ prices(localpool_manager, localpool2.id).first.update({}) }.not_to raise_error
    end

    it 'delete' do
      begin
        expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).prices.retrieve(price.id).delete }.not_to raise_error
        expect(localpool2.prices.reload).to eq []
      ensure
        Price.create(price.attributes)
      end

      begin
        expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).prices.retrieve(price.id).delete }.not_to raise_error
        expect(localpool2.prices.reload).to eq []
      ensure
        Price.create(price.attributes)
      end

      begin
        expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).prices.retrieve(price.id).delete }.not_to raise_error
        expect(localpool2.prices.reload).to eq []
      ensure
        Price.create(price.attributes)
      end
    end  
  end

  context 'billing_cycles' do

    def billing_cycles(user, id)
      Group::LocalpoolResource.retrieve(user, id).billing_cycles.collect do |l|
        l.object
      end
    end

    it 'all' do
      expect(billing_cycles(buzzn_operator, localpool1.id)).to eq []
      expect(billing_cycles(buzzn_operator, localpool2.id)).to match_array localpool2.billing_cycles.reload

      expect(billing_cycles(localpool_owner, localpool2.id)).to match_array localpool2.billing_cycles.reload
      expect(billing_cycles(localpool_manager, localpool2.id)).to match_array localpool2.billing_cycles.reload

      expect(billing_cycles(localpool_member, localpool1.id)).to eq []
    end

    it 'create' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).create_billing_cycle }.to raise_error Buzzn::ValidationError
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError
      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError

      expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).create_billing_cycle }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect{ billing_cycles(buzzn_operator, localpool2.id).first.update({}) }.not_to raise_error
    
      expect{ billing_cycles(localpool_owner, localpool2.id).first.update({}) }.not_to raise_error

      expect{ billing_cycles(localpool_manager, localpool2.id).first.update({}) }.not_to raise_error
    end

    it 'delete' do
      begin
        expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).billing_cycles.retrieve(billing_cycle.id).delete }.not_to raise_error
        expect(localpool2.billing_cycles.reload).to eq []
      ensure
        BillingCycle.create(billing_cycle.attributes)
      end

      begin
        expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).billing_cycles.retrieve(billing_cycle.id).delete }.not_to raise_error
        expect(localpool2.billing_cycles.reload).to eq []
      ensure
        BillingCycle.create(billing_cycle.attributes)
      end

      begin
        expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).billing_cycles.retrieve(billing_cycle.id).delete }.not_to raise_error
        expect(localpool2.billing_cycles.reload).to eq []
      ensure
        BillingCycle.create(billing_cycle.attributes)
      end
    end  
  end
  
  context 'users' do

    def users(user, id)
      Group::LocalpoolResource.retrieve(user, id).users.collect do |l|
        l.object
      end
    end

    it 'all' do
      expect(users(buzzn_operator, localpool1.id)).to match_array localpool1.users.reload
      expect(users(buzzn_operator, localpool2.id)).to match_array localpool2.users.reload

      expect(users(localpool_owner, localpool2.id)).to match_array localpool2.users

      expect(users(localpool_manager, localpool2.id)).to match_array localpool2.users
      
      expect(users(localpool_member, localpool1.id)).to match_array [localpool_member]
    end

    it 'update' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).users.first.update({}) }.not_to raise_error
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).users.first.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).users.first.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).users.first.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).users.first.update({}) }.not_to raise_error
    end

    it 'delete' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).users.retrieve(localpool_member2.id).delete }.not_to raise_error
      expect(localpool1.users.reload).to eq [localpool_member]

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).users.first.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).users.first.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Group::LocalpoolResource.retrieve(localpool_member, localpool1.id).users.first.delete }.to raise_error Buzzn::PermissionDenied
    end
  end
  
  context 'metering_point_operator_contract' do

    it 'retrieve' do
      expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).metering_point_operator_contract).to be_nil
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).metering_point_operator_contract! }.to raise_error Buzzn::RecordNotFound

      expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).metering_point_operator_contract.object).to eq mpoc
      expect(Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).metering_point_operator_contract.object).to eq mpoc
      expect(Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).metering_point_operator_contract.object).to eq mpoc

      expect{ Group::LocalpoolResource.retrieve(localpool_member3, localpool2.id).metering_point_operator_contract! }.to raise_error Buzzn::PermissionDenied
      expect(Group::LocalpoolResource.retrieve(localpool_member3, localpool2.id).metering_point_operator_contract).to be_nil
    end

    it 'update' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).metering_point_operator_contract.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).metering_point_operator_contract.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).metering_point_operator_contract.update({}) }.not_to raise_error
    end

    it 'delete' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).metering_point_operator_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).metering_point_operator_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).metering_point_operator_contract.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'localpool_processing_contract' do

    it 'retrieve' do
      expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).localpool_processing_contract).to be_nil
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool1.id).localpool_processing_contract! }.to raise_error Buzzn::RecordNotFound

      expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).localpool_processing_contract.object).to eq lpc
      expect(Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).localpool_processing_contract.object).to eq lpc
      expect(Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).localpool_processing_contract.object).to eq lpc

      expect{ Group::LocalpoolResource.retrieve(localpool_member3, localpool2.id).localpool_processing_contract! }.to raise_error Buzzn::PermissionDenied
      expect(Group::LocalpoolResource.retrieve(localpool_member3, localpool2.id).localpool_processing_contract).to be_nil
    end

    it 'update' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).localpool_processing_contract.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).localpool_processing_contract.update({}) }.not_to raise_error

      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).localpool_processing_contract.update({}) }.not_to raise_error
    end

    it 'delete' do
      expect{ Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).localpool_processing_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).localpool_processing_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).localpool_processing_contract.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'registers' do

    def registers(user, id)
      Group::LocalpoolResource.retrieve(user, id).registers.collect do |l|
        l.object
      end
    end

    it 'all' do
      expect(registers(buzzn_operator, localpool1.id)).to match_array localpool1.registers.reload
      expect(registers(buzzn_operator, localpool2.id)).to match_array localpool2.registers.reload

      expect(registers(localpool_owner, localpool2.id)).to match_array localpool2.registers.reload
      expect(registers(localpool_manager, localpool2.id)).to match_array localpool2.registers.reload
      expect(registers(localpool_member, localpool1.id)).to match_array []

      expect(registers(localpool_member3, localpool2.id)).to match_array localpool2.registers.input.real
      
      expect(registers(localpool_member4, localpool2.id)).to match_array []

      expect{ registers(localpool_member, localpool2.id) }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect{ registers(buzzn_operator, localpool2.id).first.update({}) }.not_to raise_error
    
      expect{ registers(localpool_owner, localpool2.id).first.update({}) }.not_to raise_error

      expect{ registers(localpool_manager, localpool2.id).first.update({}) }.not_to raise_error
    end

    it 'retrieve' do
      expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).registers.retrieve(register.id).object).to eq register

      expect(Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).registers.retrieve(register.id).object).to eq register

      expect(Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).registers.retrieve(register.id).object).to eq register

      expect(Group::LocalpoolResource.retrieve(localpool_member3, localpool2.id).registers.retrieve(register.id).object).to eq register

      expect{ Group::LocalpoolResource.retrieve(localpool_member4, localpool2.id).registers.retrieve(register.id) }.to raise_error Buzzn::PermissionDenied
    end  
  end

  context 'localpool_power_taker_contracts' do

    def localpool_power_taker_contracts(user, id)
      Group::LocalpoolResource.retrieve(user, id).localpool_power_taker_contracts.collect do |l|
        l.object
      end
    end

    it 'all' do
      expect(localpool_power_taker_contracts(buzzn_operator, localpool1.id)).to match_array localpool1.localpool_power_taker_contracts.reload
      expect(localpool_power_taker_contracts(buzzn_operator, localpool2.id)).to match_array localpool2.localpool_power_taker_contracts.reload

      expect(localpool_power_taker_contracts(localpool_owner, localpool2.id)).to match_array localpool2.localpool_power_taker_contracts.reload
      expect(localpool_power_taker_contracts(localpool_manager, localpool2.id)).to match_array localpool2.localpool_power_taker_contracts.reload
      expect(localpool_power_taker_contracts(localpool_member, localpool1.id)).to match_array []

      expect(localpool_power_taker_contracts(localpool_member3, localpool2.id)).to match_array localpool2.localpool_power_taker_contracts
      
      expect(localpool_power_taker_contracts(localpool_member4, localpool2.id)).to match_array []

      expect{ localpool_power_taker_contracts(localpool_member, localpool2.id) }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect{ localpool_power_taker_contracts(buzzn_operator, localpool2.id).first.update({}) }.not_to raise_error
    
      expect{ localpool_power_taker_contracts(localpool_owner, localpool2.id).first.update({}) }.not_to raise_error

      expect{ localpool_power_taker_contracts(localpool_manager, localpool2.id).first.update({}) }.not_to raise_error
    end

    it 'retrieve' do
      expect(Group::LocalpoolResource.retrieve(buzzn_operator, localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Group::LocalpoolResource.retrieve(localpool_owner, localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Group::LocalpoolResource.retrieve(localpool_manager, localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Group::LocalpoolResource.retrieve(localpool_member3, localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect{ Group::LocalpoolResource.retrieve(localpool_member4, localpool2.id).localpool_power_taker_contracts.retrieve(contract.id) }.to raise_error Buzzn::PermissionDenied
    end  
  end
end
