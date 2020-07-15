describe 'Schemas::Invariants::Contract::CreateBilling', order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:meter) { create(:meter, :real) }
  let(:register_meta) { create(:meta) }
  let(:lppt) do
    create(:contract, :is_localpool_powertaker_contract,
           register_meta: register_meta)
  end

  context 'tariff' do

    let(:tariff) { create(:tariff, group: localpool) }

    subject do
      subject = Schemas::Support::ActiveRecordValidator.new(lppt)
      Schemas::PreConditions::Contract::CreateBilling.call(subject).errors[:tariffs]
    end

    context 'without' do
      it { is_expected.to eq(['size cannot be less than 1']) }
    end

    context 'with' do
      before do
        lppt.tariffs << tariff
        lppt.save
      end
      it { is_expected.to be_nil }
    end

  end

  context 'register_meta' do

    subject do
      subject = Schemas::Support::ActiveRecordValidator.new(lppt)
      Schemas::PreConditions::Contract::CreateBilling.call(subject).errors[:register_meta]
    end

    context 'without a meter' do
      it do
        expect(subject[:registers]).not_to be_nil
        expect(subject[:registers]).to eq(['size cannot be less than 1'])
      end
    end

    context 'with a meter' do
      before do
        register_meta.registers << meter.registers.first
      end

      it do
        expect(subject[:registers]).to eq(['all registers must have a device_setup or change_meter_2 reading or similar'])
      end

    end

  end

end
