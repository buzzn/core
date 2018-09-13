describe Contract::BaseResource do

  entity(:admin) { create(:account, :buzzn_operator) }
  entity!(:buzzn) { Organization::Market.buzzn }
  entity(:localpool) do
    localpool = create(:group, :localpool)
    localpool.owner.bank_accounts << create(:bank_account, owner: localpool.owner)
    localpool
  end

  entity!(:metering_point_operator) do
    create(:contract, :metering_point_operator, localpool: localpool)
  end
  entity!(:localpool_processing) do
    create(:contract, :localpool_processing, localpool: localpool)
  end
  entity!(:localpool_power_taker) do
    create(:contract, :localpool_powertaker, localpool: localpool)
  end

  let(:base_attributes) do ['id', 'type', 'created_at', 'updated_at',
                            'status',
                            'full_contract_number',
                            'signing_date',
                            'termination_date',
                            'last_date',
                            'updatable',
                            'documentable',
                            'deletable'] end
  let!(:all) { [metering_point_operator, localpool_processing, localpool_power_taker] }

  let(:resources) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).contracts }

  it 'retrieve' do
    all.each do |contract|
      attrs = resources.retrieve(contract.id).to_h
      expect(attrs.keys & base_attributes).to match_array base_attributes
    end
  end

  it 'retrieve all - ids + types' do
    expected = all.collect { |c| [c.class.to_s, c.id] }
    result = resources.collect do |r|
      [r.object.class.to_s, r.id]
    end
    expect(result).to match_array expected
  end

  [:customer, :customer_bank_account, :contractor].each do |name|
    it "nested #{name}" do
      all.each do |contract|
        obj = resources.retrieve(contract.id)
        expect(obj.send(name)).to be_an Buzzn::Resource::Base
        expect(obj.send("#{name}!")).to be_an Buzzn::Resource::Base
      end
    end
  end

  it 'constraints' do
    resources.each do |contract|
      expect(Schemas::Constraints::Contract::Base.call(contract)).to be_success
    end
  end

  context 'invariants' do

    it 'valid' do
      resources.each do |contract|
        contract.object.update begin_date: nil, termination_date: nil, end_date: nil
        expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base

        contract.object.update begin_date: Date.today
        expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base

        contract.object.update termination_date: Date.today
        expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base

        contract.object.update end_date: Date.today
        expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base
      end
    end

    context 'invalid' do
      it 'missing begin_date and termination_date' do
        resources.each do |contract|
          contract.object.update begin_date: nil, termination_date: nil, end_date: Date.today
          expect(contract).not_to have_valid_invariants Schemas::Invariants::Contract::Base
          expect(Schemas::Invariants::Contract::Base.call(contract).messages).to eq(:begin_date=>['must be filled'], :termination_date=>['must be filled'])
        end
      end

      it 'missing begin_date' do
        resources.each do |contract|
          contract.object.update begin_date: nil, termination_date: Date.today, end_date: Date.today
          expect(contract).not_to have_valid_invariants Schemas::Invariants::Contract::Base
          expect(Schemas::Invariants::Contract::Base.call(contract).messages).to eq(:begin_date=>['must be filled'])
        end
      end

      it 'missing termination date' do
        resources.each do |contract|
          contract.object.update begin_date: Date.today, termination_date: nil, end_date: Date.today
          expect(contract).not_to have_valid_invariants Schemas::Invariants::Contract::Base
          expect(Schemas::Invariants::Contract::Base.call(contract).messages).to eq(:termination_date=>['must be filled'])
        end
      end
    end
  end

  it 'status' do
    resources.each do |contract|
      contract.object.update begin_date: nil
      contract.object.update termination_date: nil
      contract.object.update end_date: nil
      contract.object.update signing_date: nil

      expect(contract.status).to eq Contract::Base::ONBOARDING

      contract.object.update signing_date: Date.today
      expect(contract.status).to eq Contract::Base::SIGNED

      contract.object.update begin_date: Date.today
      expect(contract.status).to eq Contract::Base::ACTIVE

      contract.object.update termination_date: Date.today
      expect(contract.status).to eq Contract::Base::TERMINATED

      contract.object.update end_date: Date.today
      expect(contract.status).to eq Contract::Base::ENDED
    end
  end

  describe Contract::MeteringPointOperatorResource do

    it 'retrieve - ids + types' do
      result = resources.select {|r| r.object.is_a?(Contract::MeteringPointOperator)}
                 .collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['contract_metering_point_operator', metering_point_operator.id]]
    end

    it 'retrieve' do
      attributes = ['begin_date', 'metering_point_operator_name'] + base_attributes
      attrs = resources.retrieve(metering_point_operator.id).to_h
      expect(attrs['id']).to eq metering_point_operator.id
      expect(attrs['type']).to eq 'contract_metering_point_operator'
      expect(attrs.keys).to match_array attributes
    end
  end

  describe Contract::LocalpoolProcessingResource do

    it 'retrieve all - ids + types' do
      result = resources.select {|r| r.object.is_a?(Contract::LocalpoolProcessing)}
                 .collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['contract_localpool_processing', localpool_processing.id]]
    end

    it 'retrieve' do
      attributes = ['begin_date', 'tax_number', 'allowed_actions'] + base_attributes
      attrs = resources.retrieve(localpool_processing.id).to_h
      expect(attrs['id']).to eq localpool_processing.id
      expect(attrs['type']).to eq 'contract_localpool_processing'
      expect(attrs.keys).to match_array attributes
    end
  end

  describe Contract::LocalpoolPowerTakerResource do

    it 'retrieve - ids + types' do
      result = resources.select {|r| r.object.is_a?(Contract::LocalpoolPowerTaker)}
                 .collect do |r|
        [r.object.class, r.id]
      end
      expect(result).to eq [[Contract::LocalpoolPowerTaker, localpool_power_taker.id]]
    end

    it 'retrieve' do
      attributes = ['begin_date',
                    'forecast_kwh_pa',
                    'renewable_energy_law_taxation',
                    'third_party_billing_number',
                    'third_party_renter_number',
                    'old_supplier_name',
                    'old_customer_number',
                    'old_account_number',
                    'share_register_with_group',
                    'share_register_publicly',
                    'mandate_reference'] + base_attributes
      attrs = resources.retrieve(localpool_power_taker.id).to_h
      expect(attrs['id']).to eq localpool_power_taker.id
      expect(attrs['type']).to eq 'contract_localpool_power_taker'
      expect(attrs.keys).to match_array attributes
    end
  end
end
