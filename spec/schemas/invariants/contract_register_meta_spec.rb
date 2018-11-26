require 'buzzn/schemas/invariants/contract/localpool_third_party'
require 'buzzn/schemas/invariants/contract/localpool_powertaker'

describe 'Schemas::Invariants::Contract::Localpool' do

  entity(:person)       { create(:person) }
  entity(:organization) { create(:organization) }
  entity(:tariff)       { create(:tariff, group: create(:group, :localpool)) }
  entity(:localpool)    { tariff.group }
  entity(:other_localpool) { create(:group, :localpool) }

  entity!(:register_meta) { third_party.register_meta }
  entity(:processing) { create(:contract, :localpool_processing, localpool: localpool) }
  entity(:powertaker) do
    processing
    create(:contract, :localpool_powertaker, localpool: localpool, register_meta: register_meta, tariffs: [tariff])
  end
  entity(:third_party) do
    processing
    create(:contract, :localpool_third_party, localpool: localpool)
  end
  entity(:metering_point_operator) { create(:contract, :metering_point_operator, localpool: localpool) }

  shared_examples 'invariants of register_meta' do |contract_name|

    let(:contract) { send(contract_name) }
    let(:tested_invariants) { contract.invariant.errors[:register_meta] }

    subject { tested_invariants }

    context 'when there is no register_meta' do
      before do
        contract.register_meta = nil
      end
      it { is_expected.to eq(['must be filled']) }
    end

    context 'when there is a register_meta' do
      before do
        contract.register_meta = register_meta
      end
      it { is_expected.to be_nil }
    end

    after do
      contract.register_meta = register_meta
    end
  end

  context 'powertaker contract' do
    before { powertaker.contractor = localpool.owner }

    describe 'register_meta' do
      it_behaves_like 'invariants of register_meta', :powertaker
    end
  end

  context 'third party contract' do
    describe 'register_meta' do
      it_behaves_like 'invariants of register_meta', :third_party
    end
  end
end
