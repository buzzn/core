describe "#{Buzzn::Permission} - #{Admin::LocalpoolResource}" do

  def update(resource, params = nil)
    params ||= {updated_at: resource.object.updated_at}
    resource.update(params)
  end

  def all(user)
    Admin::LocalpoolResource.all(user).objects
  end

  entity(:buzzn_operator)    { create(:account, :buzzn_operator) }
  entity(:localpool_owner)   { create(:account) }
  entity(:localpool_manager) { create(:account) }
  entity(:localpool_member)  { create(:account) }
  entity(:localpool_member2) { create(:account) }
  entity(:localpool_member3) { create(:account) }
  entity(:localpool_member4) { create(:account) }
  entity(:user)              { create(:account) }
  let(:anonymous)            { nil }

  entity!(:localpool1) do
    pool = create(:group, :localpool)
    localpool_member.person.add_role(Role::GROUP_MEMBER, pool)
    localpool_member2.person.add_role(Role::GROUP_MEMBER, pool)
    pool
  end

  entity!(:localpool2) do
    pool = create(:group, :localpool)
    localpool_owner.person.add_role(Role::GROUP_OWNER, pool)
    localpool_manager.person.add_role(Role::GROUP_ADMIN, pool)
    localpool_member3.person.add_role(Role::GROUP_MEMBER, pool)
    localpool_member4.person.add_role(Role::GROUP_MEMBER, pool)
    meter = create(:meter, :real, group: pool)
    create(:contract, :localpool_powertaker,
           localpool: pool,
           customer: localpool_member3.person,
           register_meta: meter.registers.first.meta)
    pool.registers.each do |r|
      r.update(address: create(:address)) unless r.valid?
    end
    pool
  end

  entity!(:localpool3) { create(:group, :localpool) }

  let(:contract) { localpool2.localpool_power_taker_contracts.first }
  let(:register) { localpool2.registers.real.input.first }

  entity!(:mpoc) do
    create(:contract, :metering_point_operator, localpool: localpool2)
  end
  entity!(:lpc) do
    create(:contract, :localpool_processing, localpool: localpool2)
  end

  entity(:tariff) { create(:tariff, group: localpool2)}
  entity!(:billing_cycle) { create(:billing_cycle, localpool: localpool2) }

  xit 'create' do
    expect do
      a = Admin::LocalpoolResource.create(buzzn_operator, name: 'first')
      a.object.delete
    end.not_to raise_error

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
    expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).updatable?).to be true
    expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).updatable?).to be true

    expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).updatable?).to be true

    expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).updatable?).to be true

    expect(Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).updatable?).to be false
  end

  it 'delete' do
    expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).deletable?).to be true

    expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool3.id).deletable?).to be true

    expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).deletable?).to be false

    expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).deletable?).to be false

    expect(Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).deletable?).to be false
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

    xit 'create' do

      # FIXME the permissions need to be handed over to the collection
      #       and ask the createable? on the collection itself

      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).create_tariff(build(:tariff).attributes) }.not_to raise_error
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).create_tariff(build(:tariff).attributes) }.not_to raise_error

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).create_tariff }.to raise_error Buzzn::PermissionDenied
      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).create_tariff }.to raise_error Buzzn::PermissionDenied

      expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).create_tariff }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).tariffs.first.updatable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).tariffs.first.updatable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).tariffs.first.updatable?).to be false
    end

    it 'delete' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).tariffs.retrieve(tariff.id).deletable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).tariffs.retrieve(tariff.id).deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).tariffs.retrieve(tariff.id).deletable?).to be false
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

    xit 'create' do

      # FIXME the permissions need to be handed over to the collection
      #       and ask the createable? on the collection itself

      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).create_billing_cycle }.to raise_error Buzzn::ValidationError
      expect{ Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError

      expect{ Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError
      expect{ Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).create_billing_cycle }.to raise_error Buzzn::ValidationError

      expect{ Admin::LocalpoolResource.all(localpool_member).retrieve(localpool1.id).create_billing_cycle }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).billing_cycles.first.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).billing_cycles.first.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).billing_cycles.first.updatable?).to be true
    end

    it 'delete' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).billing_cycles.retrieve(billing_cycle.id).deletable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).billing_cycles.retrieve(billing_cycle.id).deletable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).billing_cycles.retrieve(billing_cycle.id).deletable?).to be true
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
      # TODO not sure what GROUP_MEMBER means - outdated concept
      #expect(persons(localpool_member, localpool1.id)).to match_array [localpool_member.person]
    end

    it 'update' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).persons.first.updatable?).to be true
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).persons.first.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).persons.first.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).persons.first.updatable?).to be true
    end

    it 'delete' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool1.id).persons.retrieve(localpool_member2.person.id).deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).persons.first.deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).persons.first.deletable?).to be false
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
        expect(contract.updatable?).to be true
      end
    end

    it 'delete' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).metering_point_operator_contract.deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).metering_point_operator_contract.deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).metering_point_operator_contract.deletable?).to be false
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
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_processing_contract.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_processing_contract.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_processing_contract.updatable?).to be true
    end

    it 'delete' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_processing_contract.deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_processing_contract.deletable?).to be false

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_processing_contract.deletable?).to be false
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

      expect(localpool_power_taker_contracts(localpool_member4, localpool2.id)).to match_array []

      expect{ localpool_power_taker_contracts(localpool_member, localpool2.id) }.to raise_error Buzzn::PermissionDenied
    end

    it 'update' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_power_taker_contracts.first.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_power_taker_contracts.first.updatable?).to be true

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_power_taker_contracts.first.updatable?).to be true
    end

    it 'retrieve' do
      expect(Admin::LocalpoolResource.all(buzzn_operator).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Admin::LocalpoolResource.all(localpool_owner).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect(Admin::LocalpoolResource.all(localpool_manager).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id).object).to eq contract

      expect{ Admin::LocalpoolResource.all(localpool_member4).retrieve(localpool2.id).localpool_power_taker_contracts.retrieve(contract.id) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
