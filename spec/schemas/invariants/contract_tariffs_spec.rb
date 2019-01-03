require 'buzzn/schemas/invariants/contract/localpool_third_party'
require 'buzzn/schemas/invariants/contract/localpool_powertaker'

describe 'Schemas::Invariants::Contract::Localpool' do

  entity(:tariff)       { create(:tariff, group: localpool) }
  entity(:tariff2)      { create(:tariff, group: localpool, begin_date: tariff.begin_date - 2.year) }
  entity(:localpool)    { create(:group, :localpool) }
  entity(:other_localpool) { create(:group, :localpool) }

  entity(:processing)              { create(:contract, :localpool_processing,    localpool: localpool, tariffs: [tariff]) }
  entity(:powertaker) do
    processing
    create(:contract, :localpool_powertaker,    localpool: localpool, tariffs: [tariff])
  end

  entity(:metering_point_operator) { create(:contract, :metering_point_operator, localpool: localpool, tariffs: [tariff]) }

  [:powertaker, :processing, :metering_point_operator].each do |name|
    context "#{name} tariff invariants" do

      let(:contract) { send(name) }
      let(:tested_invariants) { contract.invariant.errors[:tariffs] }

      subject { tested_invariants }

      before do
        contract.update(localpool: localpool)
        contract.tariffs << tariff unless contract.tariffs.include?(tariff)
        contract.tariffs.delete(tariff2)
        # just update tariff for this test
        tariff.update_column(:group_id, localpool.id)
      end

      context 'when contract has no localpool' do
        before do
          contract.update(localpool: nil)
          localpool.tariffs.reload
        end
        it { is_expected.to be_nil }
      end

      context 'when all tariffs belong to localpool' do
        before do
          localpool.tariffs.reload
        end
        it { is_expected.to be_nil }
      end

      context 'when tariffs do belong to different localpool' do
        before do
          # just update tariff for this test
          tariff.update_column(:group_id, other_localpool.id)
          localpool.tariffs.reload
        end
        it { is_expected.to eq(['all tariff.group must match contract.localpool']) }
      end
    end
  end
end
