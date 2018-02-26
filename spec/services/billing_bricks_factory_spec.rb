describe 'Services::BillingBricksFactory' do

  let(:group)            { build(:localpool) }
  let(:begin_date)       { Date.new(2018, 1, 1) }
  let(:end_date)         { Date.new(2018, 12, 31) }
  let(:args)             { { begin_date: begin_date, end_date: end_date, group: group } }
  let(:factory)          { Services::BillingBricksFactory.new(args) }

  it 'can be initialized' do
    expect(factory).to be_instance_of(Services::BillingBricksFactory)
  end

  describe 'bricks_by_market_location' do
    context 'when group has no market locations' do
      let(:group) { create(:localpool, market_locations: []) }
      it 'returns an empty array' do
        expect(factory.bricks_by_market_location).to eq([])
      end
    end

    context 'when group has one market location' do
      context 'when market location has one contract and register' do
        let(:register)        { create(:register, :consumption, :with_market_location) }
        let(:market_location) { create(:market_location, :with_contract, register: register) }
        let(:group)           { create(:localpool, market_locations: [market_location]) }

        it 'returns one item' do
          data = factory.bricks_by_market_location
          expect(data.first[:name]).to eq(market_location.name)
          expect(data.size).to eq(1)
        end

        it 'contains one brick for the whole date range' do
          data = factory.bricks_by_market_location
          expect(data.first[:bricks].size).to equal(1)
          expected_brick = BillingBrick.new(
            begin_date: args[:begin_date],
            end_date: args[:end_date],
            status: :open,
            type: :power_taker,
            market_location: market_location
          )
          expect(data.first[:bricks].size).to eq(1)
          expect(data.first[:bricks].first).to eq(expected_brick)
        end

        # NOTE: be aware this case will have to create two billings. Probably best to redesign from the top.
        context 'when market location has two contracts of different types', :skip do
          # gap contract that started 1 month before to the billing period
          let!(:contract_1) do
            create(:contract, :localpool_gap, begin_date: begin_date - 1.month, end_date: begin_date + 1.month)
          end
          # regular powertaker that started 1 month into the billing period and is still running
          let!(:contract_2) do
            create(:contract, :localpool_powertaker, begin_date: begin_date + 1.month, end_date: nil)
          end
          let!(:market_location) { create(:market_location, contracts: [contract_1, contract_2], register: register) }

          it 'returns one item' do
            data = factory.bricks_by_market_location
            expect(data.first[:name]).to eq(market_location.name)
            expect(data.size).to eq(1)
          end

          it 'contains two bricks, one for each contract, with correct type and date range' do
            data = factory.bricks_by_market_location
            expect(data.first[:bricks].size).to eq(2)
          end
        end
      end
    end
  end

end
