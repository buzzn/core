require 'buzzn/schemas/invariants/contract/localpool_third_party'
require 'buzzn/schemas/invariants/contract/localpool_powertaker'

describe 'Schemas::Invariants::Contract::Localpool' do

  entity(:person)       { create(:person) }
  entity(:organization) { create(:organization) }
  entity(:tariff)       { create(:tariff, group: create(:group, :localpool)) }
  entity(:localpool)    { tariff.group }
  entity(:other_localpool) { create(:group, :localpool) }

  entity(:third_party) { create(:contract, :localpool_third_party, localpool: localpool) }
  entity!(:market_location) { third_party.market_location }
  entity(:powertaker) { create(:contract, :localpool_powertaker,    localpool: localpool, market_location: market_location, tariffs: [tariff]) }
  entity(:processing) { create(:contract, :localpool_processing,    localpool: localpool) }
  entity(:metering_point_operator) { create(:contract, :metering_point_operator, localpool: localpool) }

  shared_examples 'invariants of market_location' do |contract_name|

    let(:contract) { send(contract_name) }
    let(:tested_invariants) { contract.invariant.errors[:market_location] }

    subject { tested_invariants }

    context 'when there is no market_location' do
      before do
        contract.market_location = nil
      end
      it { is_expected.to eq(['must be filled']) }
    end

    context 'when there is a market_location' do
      before do
        contract.market_location = market_location
      end
      it { is_expected.to be_nil }
    end

    after do
      contract.market_location = market_location
    end
  end

  context 'powertaker contract' do
    before { powertaker.contractor = localpool.owner }

    describe 'market_location' do
      it_behaves_like 'invariants of market_location', :powertaker
    end
  end

  context 'third party contract' do
    describe 'market_location' do
      it_behaves_like 'invariants of market_location', :third_party
    end
  end
end
