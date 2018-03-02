describe 'Services::BillingBricksFactory' do

  describe 'bricks_by_market_location' do

    # RSpec::Matchers.define :equal_brick do |expected|
    #   match do |actual|
    #     actual.invariant.success?
    #   end

    #   failure_message do |actual|
    #     "expected #{actual.class}##{actual.id} to have valid invariants: #{actual.invariant.errors.keys.join(',')}"
    #   end

    #   failure_message_when_negated do |actual|
    #     "expected #{actual.class}##{actual.id} to have valid invariants: #{actual.invariant.errors.keys.join(',')}"
    #   end
    # end

    let(:group)      { build(:localpool) }
    let(:date_range) { Date.new(2018, 1, 1)...Date.new(2019, 1, 1) }
    let(:args)       { { date_range: date_range, group: group } }
    subject          { Services::BillingBricksFactory.new.bricks_by_market_location(args) }

    context 'when group has no market locations' do
      let(:group) { create(:localpool, market_locations: []) }
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when group has one market location' do

      context 'when market location has one contract' do

        context 'when contract has no existing billings' do
          let(:market_location) { create(:market_location, :with_contract, register: :consumption) }
          let(:group)           { create(:localpool, market_locations: [market_location]) }

          it 'returns one market location' do
            expect(subject.size).to eq(1)
            expect(subject.first[:market_location]).to eq(market_location)
          end

          it 'contains one brick for the whole date range' do

            expect(subject.first[:bricks].size).to equal(1)
            expect(subject.first[:bricks].size).to eq(1)
            expect(subject.first[:bricks].first).to have_attributes(
              date_range:      args[:date_range],
              status:          'open',
              contract_type:   'power_taker'
            )
          end
        end

        context 'when contract has an existing billing' do
          let(:market_location)           { create(:market_location, :with_contract, register: :consumption) }
          let(:group)                     { create(:localpool, market_locations: [market_location]) }
          let(:already_billed_date_range) { date_range.first...date_range.last - 2.months }
          let(:existing_billing)          { create(:billing, date_range: already_billed_date_range, contract: market_location.contracts.last) }
          let!(:existing_brick)           { create(:billing_brick, billing: existing_billing) }

          it 'contains one brick for the existing billing and a new one' do
            expect(subject.first[:bricks].size).to eq(2)
            brick1, brick2 = subject.first[:bricks]
            expect(brick1.date_range).to eq(existing_brick.date_range)
            expect(brick2.date_range).to eq(already_billed_date_range.last...date_range.last)
            expect(brick2.status).to eq('open')
          end
        end
      end

      context 'when market location has two contracts' do
        let(:contracts) do
          [create(:contract, :localpool_gap, begin_date: date_range.first - 1.month, end_date: date_range.first + 1.month),
           create(:contract, :localpool_powertaker, begin_date: date_range.first + 1.month, end_date: nil)]
        end
        let!(:market_location) { create(:market_location, contracts: contracts, register: :consumption) }
        let(:group)            { create(:localpool, market_locations: [market_location]) }

        it 'returns one market location' do
          expect(subject.size).to eq(1)
          expect(subject.first[:market_location]).to eq(market_location)
        end

        it 'returns two bricks' do
          expect(subject.first[:bricks].size).to eq(2)
          brick1, brick2 = subject.first[:bricks]
          expect(brick1).to have_attributes(
            date_range: date_range.first...(date_range.first + 1.month),
            status: 'open',
            contract_type: 'gap'
          )
          expect(brick2).to have_attributes(
            date_range: (date_range.first + 1.month)...date_range.last,
            status: 'open',
            contract_type: 'power_taker'
          )
        end
      end
    end
  end

end
