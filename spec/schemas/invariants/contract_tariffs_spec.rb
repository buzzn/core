require 'buzzn/schemas/invariants/contract/localpool_third_party'
require 'buzzn/schemas/invariants/contract/localpool_powertaker'

describe 'Schemas::Invariants::Contract::Localpool' do

  entity(:tariff)       { create(:tariff, group: localpool) }
  entity(:localpool)    { create(:localpool) }
  entity(:other_localpool)    { create(:localpool) }

  entity(:powertaker)              { create(:contract, :localpool_powertaker,    localpool: localpool, tariffs: [tariff]) }
  entity(:processing)              { create(:contract, :localpool_processing,    localpool: localpool, tariffs: [tariff]) }
  entity(:metering_point_operator) { create(:contract, :metering_point_operator, localpool: localpool, tariffs: [tariff]) }

  [:powertaker, :processing, :metering_point_operator].each do |name|
    context "#{name} tariff invariants" do

      let(:contract) { send(name) }
      let(:tested_invariants) { contract.invariant.errors[:tariffs] }

      subject { tested_invariants }

      context "when contract has no localpool" do
        before do
          contract.update(localpool: nil)
          tariff.update(group: localpool)
          localpool.tariffs.reload
        end
        it { is_expected.to be_nil }
      end

      context "when all tariffs belong to localpool" do
        before do
          contract.update(localpool: localpool)
          tariff.update(group: localpool)
          localpool.tariffs.reload
        end
        it { is_expected.to be_nil }
      end

      context "when tariffs do belong to different localpool" do
        before do
          contract.update(localpool: localpool)
          tariff.update(group: other_localpool)
          localpool.tariffs.reload
        end
        it { is_expected.to eq(['all tariff.group must match contract.localpool']) }
      end
    end
  end
end
