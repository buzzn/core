require 'buzzn/schemas/invariants/contract/localpool_third_party'
require 'buzzn/schemas/invariants/contract/localpool_powertaker'

describe 'Schemas::Invariants::Contract::Localpool' do

  entity(:person)       { create(:person) }
  entity(:organization) { create(:organization) }
  entity(:tariff)       { create(:tariff, group: create(:localpool)) }
  entity(:localpool)    { tariff.group }
  entity(:other_localpool) { create(:localpool) }

  entity(:third_party)  { create(:contract, :localpool_third_party, localpool: localpool) }
  entity(:market_location)         { third_party.market_location }
  entity(:powertaker)              { create(:contract, :localpool_powertaker,    localpool: localpool, market_location: market_location, tariffs: [tariff]) }
  entity(:processing)              { create(:contract, :localpool_processing,    localpool: localpool) }
  entity(:metering_point_operator) { create(:contract, :metering_point_operator, localpool: localpool) }

  shared_examples 'invariants of localpool' do |contract|

    let(:tested_invariants) { contract.invariant.errors[:localpool] }

    subject { tested_invariants }

    context 'when there is no localpool' do
      before do
        contract.localpool = nil
      end
      it { is_expected.to eq(['must be filled']) }
    end

    context 'when there is a localpool' do
      before do
        contract.localpool = localpool
      end
      it { is_expected.to be_nil }
    end

    after do
      contract.localpool = localpool
    end
  end

  shared_examples 'invariants of market_location group' do |contract|

    entity(:other) { create(:localpool) }

    let(:tested_invariants) { contract.invariant.errors[:market_location] }

    subject { tested_invariants }

    context 'when market_location belongs to different group' do
      before do
        contract.market_location.register.meter.group = other
      end
      it { is_expected.to eq(['meter.group must match contract.localpool']) }
    end

    context 'when market_location belongs to same group' do
      before do
        contract.market_location.register.meter.group = contract.localpool
      end
      it { is_expected.to be_nil }
    end

    after do
      contract.market_location.register.meter.group = contract.localpool
    end
  end

  shared_examples 'invariants of market_location' do |contract|

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

  shared_examples 'invariants of contracting party' do |label, contract, expected|

    let(:tested_invariants) { contract.invariant.errors[:"#{label}"] }

    subject { tested_invariants }

    before { contract.localpool = localpool }

    context 'when there is no party' do
      before do
        contract.send("#{label}=", nil)
      end
      it { is_expected.to eq(['must be filled']) }
    end

    context 'when there is a person party' do
      before do
        contract.send("#{label}=", person)
      end
      it do
        if expected
          is_expected.to eq([expected])
        else
          is_expected.to be_nil
        end
      end
    end

    context 'when there is a organization party' do
      before do
        contract.send("#{label}=", organization)
      end
      it do
        if expected
          is_expected.to eq([expected])
        else
          is_expected.to be_nil
        end
      end
    end
  end

  context 'powertaker contract' do
    before { powertaker.contractor = localpool.owner }

    describe 'localpool' do
      it_behaves_like 'invariants of localpool', powertaker
    end

    describe 'market_location' do
      it_behaves_like 'invariants of market_location', powertaker
      it_behaves_like 'invariants of market_location group', powertaker
    end

    describe 'customer' do
      it_behaves_like 'invariants of contracting party', :customer, powertaker, nil
    end

    describe 'contractor' do
      it_behaves_like 'invariants of contracting party', :contractor, powertaker, 'must be the localpool owner'
    end
  end

  context 'processing contract' do
    describe 'localpool' do
      it_behaves_like 'invariants of localpool', processing
    end

    describe 'customer' do
      it_behaves_like 'invariants of contracting party', :customer, processing, 'must be the localpool owner'
    end

    describe 'contractor' do
      # TODO should actuall check that contractor is Buzzn Organization
      it_behaves_like 'invariants of contracting party', :contractor, processing, nil
    end
  end

  context 'metering point operator contract' do
    describe 'localpool' do
      it_behaves_like 'invariants of localpool', metering_point_operator
    end

    # TODO needs check on register (like power-taker)

    describe 'customer' do
      it_behaves_like 'invariants of contracting party', :customer, processing, 'must be the localpool owner'
    end

    describe 'contractor' do
      # TODO should actuall check that contractor is Buzzn Organization
      it_behaves_like 'invariants of contracting party', :contractor, processing, nil
    end
  end

  context 'third party contract' do
    describe 'localpool' do
      it_behaves_like 'invariants of localpool', third_party
    end

    describe 'market_location' do
      it_behaves_like 'invariants of market_location', third_party
      it_behaves_like 'invariants of market_location group', third_party
    end
  end
end
