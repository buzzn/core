describe 'Billing::BrickBuilder' do

  describe 'from_contract' do

    let(:date_range) { Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
    let(:brick)      { Billing::BrickBuilder.from_contract(contract, date_range) }

    describe 'date_range' do
      context 'when contract starts before date_range and hasn\'t ended' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first - 1.day, end_date: nil) }
        it 'has the date_range\'s begin date' do
          expect(brick.date_range).to eq(date_range.first..date_range.last)
        end
      end
      context 'when contract starts with date_range and hasn\'t ended' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first, end_date: nil) }
        it 'has the date_range\'s begin date' do
          expect(brick.date_range).to eq(date_range.first..date_range.last)
        end
      end
      context 'when contract starts in date_range and hasn\'t ended' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: nil) }
        it 'has the contract\'s begin and end dates' do
          expect(brick.date_range).to eq(contract.begin_date..date_range.last)
        end
      end
      context 'when contract starts and ends in date_range' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: date_range.last - 1.day) }
        it 'has the contract\'s begin and end dates' do
          expect(brick.date_range).to eq(contract.begin_date..contract.end_date)
        end
      end
      context 'when contract starts in and ends after date_range' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: date_range.last + 1.day) }
        it 'has the contract\'s begin and date_range\'s end date' do
          expect(brick.date_range).to eq(contract.begin_date..date_range.last)
        end
      end
    end

    describe 'type' do
      context 'when initialized with a third party contract' do
        let(:contract) { create(:contract, :localpool_third_party) }
        it 'has the type third_party' do
          expect(brick.contract_type).to eq('third_party')
        end
      end
    end

    describe 'status' do
      context 'when brick has no billing' do
        subject       { build(:billing_brick, billing: nil).status }
        it            { is_expected.to eq('open') }
      end

      context 'when brick has a billing' do
        EXPECTATIONS = {
          open:       'open',
          calculated: 'open',
          delivered:  'closed',
          settled:    'closed',
          closed:     'closed'
        }

        EXPECTATIONS.each do |billing_status, expected_brick_status|
          context "when billing status is #{billing_status}" do
            let(:billing) { build(:billing, status: billing_status) }
            subject       { build(:billing_brick, billing: billing).status }
            it "is_expected.to eq #{expected_brick_status}", :skip do
              is_expected.to eq(expected_brick_status)
            end
          end
        end
      end

    end

  end

end
