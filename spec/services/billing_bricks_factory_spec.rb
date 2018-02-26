describe 'Services::BillingBricksFactory' do

  let(:group)            { build(:localpool) }
  let(:args)             { { begin_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 12, 31), group: group } }
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

        it 'returns the market location line' do
          data = factory.bricks_by_market_location
          expect(data.first[:name]).to eq(market_location.name)
          expect(data.size).to eq(1)
        end

        it 'returns one brick' do
          data = factory.bricks_by_market_location
          expect(data.first[:bricks].size).to equal(1)
          expected_brick = BillingBrick.new(
            begin_date: args[:begin_date],
            end_date: args[:end_date],
            status: :open,
            type: :powertaker,
            market_location: market_location
          )
          expect(data.first[:bricks].size).to eq(1)
          expect(data.first[:bricks].first).to eq(expected_brick)
        end
      end
    end
  end

end
