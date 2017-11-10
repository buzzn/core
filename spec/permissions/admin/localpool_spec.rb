describe "#{Buzzn::Permission} - #{Admin::LocalpoolResource}" do

  def update(resource, params = nil)
    params ||= {updated_at: resource.object.updated_at}
    resource.update(params)
  end

  def all(user)
    Admin::LocalpoolResource.all(user).collect do |l|
      l.object
    end
  end

  entity(:buzzn_operator) do
    user = Fabricate(:user)
    user.person.add_role(Role::BUZZN_OPERATOR, nil)
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
    localpool_member.person.add_role(Role::GROUP_MEMBER, pool)
    localpool_member2.person.add_role(Role::GROUP_MEMBER, pool)
    pool
  end

  entity!(:localpool2) do
    pool = Fabricate(:localpool)
    localpool_owner.person.add_role(Role::GROUP_OWNER, pool)
    localpool_manager.person.add_role(Role::GROUP_ADMIN, pool)
    localpool_member3.person.add_role(Role::GROUP_MEMBER, pool)
    localpool_member4.person.add_role(Role::GROUP_MEMBER, pool)
    meter = Fabricate(:input_meter)
    # HACK as meter.input_register.group = pool does not work
    meter.input_register.update(group_id: pool.id)
    Fabricate(:localpool_power_taker_contract,
              localpool: pool,
              customer: localpool_member3.person,
              register: meter.input_register)
    pool.registers.each do |r|
      r.update(address: Fabricate(:address)) unless r.valid?
    end
    pool
  end

  entity!(:localpool3) { Fabricate(:localpool) }

  let(:contract) { localpool2.localpool_power_taker_contracts.first }
  let(:register) { localpool2.registers.real.input.first }

  entity!(:mpoc) { Fabricate(:metering_point_operator_contract,
                             localpool: localpool2) }
  entity!(:lpc) { Fabricate(:localpool_processing_contract,
                            localpool: localpool2) }

  entity(:tariff) { Fabricate(:tariff, group: localpool2)}
  entity!(:billing_cycle) { Fabricate(:billing_cycle, localpool: localpool2) }

  it 'create' do
    expect{ Admin::LocalpoolResource.create(buzzn_operator, {}) }.to raise_error Buzzn::ValidationError

    expect{ Admin::LocalpoolResource.create(localpool_owner, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.create(localpool_manager, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.create(localpool_member, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.create(user, {}) }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.create(anonymous, {}) }.to raise_error Buzzn::PermissionDenied
  end

  it 'all' do
    expect(all(buzzn_operator)).to match_array [localpool1, localpool2, localpool3]
    expect(all(localpool_owner)).to match_array [localpool2]
    expect(all(localpool_manager)).to match_array [localpool2]
    expect(all(localpool_member)).to match_array [localpool1]
    expect(all(user)).to match_array []
    expect(all(anonymous)).to match_array []
  end

  it 'retrieve' do
    expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).object).to eq localpool1
    expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).object).to eq localpool2

    expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).object).to eq localpool2

    expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).object).to eq localpool2

    expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool2.id) }.to raise_error Buzzn::PermissionDenied
    expect(Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).object).to eq localpool1

    expect{ Admin::LocalpoolResource.all(user).retrieve(localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect{ Admin::LocalpoolResource.all(user).retrieve(localpool2.id) }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.all(anonymous).retrieve(localpool1.id) }.to raise_error Buzzn::PermissionDenied
    expect{ Admin::LocalpoolResource.all(anonymous).retrieve(localpool2.id) }.to raise_error Buzzn::PermissionDenied
  end

  it 'update' do
    expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id)) }.not_to raise_error
    expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id)) }.not_to raise_error

    expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id)) }.not_to raise_error

    expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id)) }.not_to raise_error

    expect{ update(Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id)) }.to raise_error Buzzn::PermissionDenied
  end

  it 'delete' do
    begin
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).delete }.not_to raise_error
      expect(Group::Localpool.where(id: localpool1.id)).to eq []
    ensure
      Group::Localpool.create(localpool1.attributes)
    end

    # note this also deletes the tariffs of the localpool
    begin
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool3.id).delete }.not_to raise_error
      expect(Group::Localpool.where(id: localpool3.id)).to eq []
    ensure
      Group::Localpool.create(localpool3.attributes)
    end

    expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).delete }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).delete }.to raise_error Buzzn::PermissionDenied

    expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).delete }.to raise_error Buzzn::PermissionDenied
  end

  context 'tariffs' do

    before { tariff } # ensure at least one tariff

    def tariffs(user, id)
      Admin::LocalpoolResource.all(user).retrieve(id).tariffs.objects.reload
    end

    it 'all' do
      expect(tariffs(buzzn_operator, localpool1.id)).to match_array localpool1.tariffs.reload
      expect(tariffs(buzzn_operator, localpool2.id)).to match_array localpool2.tariffs.reload

      expect(tariffs(localpool_owner, localpool2.id)).to match_array localpool2.tariffs.reload
      expect(tariffs(localpool_manager, localpool2.id)).to match_array localpool2.tariffs.reload
      expect(tariffs(localpool_member, localpool1.id)).to match_array localpool1.tariffs.reload

      expect{ tariffs(localpool_member, localpool2.id) }.to raise_error Buzzn::PermissionDenied
    end

    it 'create' do
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).create_tariff(Fabricate.build(:tariff).attributes) }.not_to raise_error
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).create_tariff(Fabricate.build(:tariff).attributes) }.not_to raise_error

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).create_tariff }.to raise_error Buzzn::PermissionDenied
      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).create_tariff }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).create_tariff }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).tariffs.first, {}) }.to raise_error Buzzn::PermissionDenied

      expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).tariffs.first, {})  }.to raise_error Buzzn::PermissionDenied

      expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).tariffs.first, {})  }.to raise_error Buzzn::PermissionDenied
    end

    it 'delete' do
      #binding.pry
      tariffs = localpool2.tariffs.all.reject{|t| t == tariff}
      begin
        expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).tariffs.retrieve(tariff.id).delete }.not_to raise_error
        expect(localpool2.tariffs.reload).to match_array tariffs
      ensure
        Contract::Tariff.create(tariff.attributes)
      end

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).tariffs.retrieve(tariff.id).delete }.to raise_error Buzzn::PermissionDenied
      expect(localpool2.tariffs.reload).to match_array localpool2.tariffs.all

      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).tariffs.retrieve(tariff.id).delete }.to raise_error Buzzn::PermissionDenied
      expect(localpool2.tariffs.reload).to match_array localpool2.tariffs.all
    end
  end

  context 'billing_cycles' do

    def billing_cycles(user, id)
      Admin::LocalpoolResource.all(user).retrieve(id).billing_cycles.objects
    end

    it 'all' do
      expect(billing_cycles(buzzn_operator, localpool1.id)).to eq []
      expect(billing_cycles(buzzn_operator, localpool2.id)).to match_array localpool2.billing_cycles.reload

      expect(billing_cycles(localpool_owner, localpool2.id)).to match_array localpool2.billing_cycles.reload
      expect(billing_cycles(localpool_manager, localpool2.id)).to match_array localpool2.billing_cycles.reload

      expect(billing_cycles(localpool_member, localpool1.id)).to eq []
    end

    it 'create' do
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).create_billing_cycle }.to raise_error Buzzn::ValidationError
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError
      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError

      expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).create_billing_cycle }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).billing_cycles.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).billing_cycles.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).billing_cycles.first) }.not_to raise_error
    end

    it 'delete' do
      begin
        expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).billing_cycles.retrieve(billing_cycle.id).delete }.not_to raise_error
        expect(localpool2.billing_cycles.reload).to eq []
      ensure
        BillingCycle.create(billing_cycle.attributes)
      end

      begin
        expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).billing_cycles.retrieve(billing_cycle.id).delete }.not_to raise_error
        expect(localpool2.billing_cycles.reload).to eq []
      ensure
        BillingCycle.create(billing_cycle.attributes)
      end

      begin
        expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).billing_cycles.retrieve(billing_cycle.id).delete }.not_to raise_error
        expect(localpool2.billing_cycles.reload).to eq []
      ensure
        BillingCycle.create(billing_cycle.attributes)
      end
    end
  end

  context 'persons' do

    def persons(user, id)
      Admin::LocalpoolResource.all(user).retrieve(id).persons.objects
    end

    it 'all' do
      expect(persons(buzzn_operator, localpool1.id)).to match_array localpool1.persons.reload
      expect(persons(buzzn_operator, localpool2.id)).to match_array localpool2.persons.reload

      expect(persons(localpool_owner, localpool2.id)).to match_array localpool2.persons

      expect(persons(localpool_manager, localpool2.id)).to match_array localpool2.persons

      expect(persons(localpool_member, localpool1.id)).to match_array [localpool_member.person]
    end

    it 'update' do
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).persons.first) }.not_to raise_error
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).persons.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).persons.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).persons.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).persons.first) }.not_to raise_error
    end

    it 'delete' do
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).persons.retrieve(localpool_member2.person.id).delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).persons.first.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).persons.first.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).persons.first.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'metering_point_operator_contract' do

    it 'retrieve' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).metering_point_operator_contract).to be_nil
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).metering_point_operator_contract! }.to raise_error Buzzn::RecordNotFound

      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).metering_point_operator_contract.object).to eq mpoc
      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).metering_point_operator_contract.object).to eq mpoc
      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).metering_point_operator_contract.object).to eq mpoc

      expect{ Admin::LocalpoolResource.all(localpool_member3).retrieve(localpool2.id).metering_point_operator_contract! }.to raise_error Buzzn::PermissionDenied
      expect(Admin::LocalpoolResource.all(localpool_member3).retrieve(localpool2.id).metering_point_operator_contract).to be_nil
    end

    it 'update' do
      [buzzn_operator, localpool_owner, localpool_manager].each do |role|
        contract = Admin::LocalpoolResource.all(role).retrieve(localpool2.id).localpool_processing_contract
        expect { update(contract) }.not_to raise_error
      end
    end

    it 'delete' do
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).metering_point_operator_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).metering_point_operator_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).metering_point_operator_contract.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'localpool_processing_contract' do

    it 'retrieve' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).localpool_processing_contract).to be_nil
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).localpool_processing_contract! }.to raise_error Buzzn::RecordNotFound

      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_processing_contract.object).to eq lpc
      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_processing_contract.object).to eq lpc
      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_processing_contract.object).to eq lpc

      expect{ Admin::LocalpoolResource.all(localpool_member3).retrieve(localpool2.id).localpool_processing_contract! }.to raise_error Buzzn::PermissionDenied
      expect(Admin::LocalpoolResource.all(localpool_member3).retrieve(localpool2.id).localpool_processing_contract).to be_nil
    end

    it 'update' do
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_processing_contract) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_processing_contract) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_processing_contract) }.not_to raise_error
    end

    it 'delete' do
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_processing_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_processing_contract.delete }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_processing_contract.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'registers' do

    def registers(user, id)
      Admin::LocalpoolResource.all(user).retrieve(id).registers.objects
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
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).registers.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).registers.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).registers.first) }.not_to raise_error
    end

    it 'retrieve' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).registers.retrieve(register.id).object).to eq register

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).registers.retrieve(register.id).object).to eq register

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).registers.retrieve(register.id).object).to eq register

      expect(Admin::LocalpoolResource.all(localpool_member3).retrieve(localpool2.id).registers.retrieve(register.id).object).to eq register

      expect{ Admin::LocalpoolResource.all(localpool_member4).retrieve(localpool2.id).registers.retrieve(register.id) }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'localpool_power_taker_contracts' do

    def localpool_power_taker_contracts(user, id)
      Admin::LocalpoolResource.all(user).retrieve(id).localpool_power_taker_contracts.objects
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
      expect{ update(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_power_taker_contracts.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_power_taker_contracts.first) }.not_to raise_error

      expect{ update(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_power_taker_contracts.first) }.not_to raise_error
    end

    it 'retrieve' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Admin::LocalpoolResource.all(localpool_member3).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect{ Admin::LocalpoolResource.all(localpool_member4).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
