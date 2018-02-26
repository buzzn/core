describe 'Services::BillingBricksFactory' do

  let(:contracts)        { [create(:contract, :localpool_powertaker)] }
  let(:register)         { create(:register, :consumption, :with_market_location) }
  let(:market_locations) { [register.market_location] }
  let(:group)            { create(:localpool, market_locations: market_locations) }
  let(:args)             { { start_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 12, 31), group: group } }
  let(:factory)          { Services::BillingBricksFactory.new(args) }

  it 'can be initialized' do
    expect(factory).to be_instance_of(Services::BillingBricksFactory)
  end

  describe 'bricks_by_market_location' do
    context 'when group has no market locations' do
      let(:market_locations) { [] }
      it 'returns an empty array' do
        expect(factory.bricks_by_market_location).to eq([])
      end
    end

    context 'when group has a market location' do
      it 'returns the bricks for that location' do
        data = factory.bricks_by_market_location
        expect(data.first[:name]).to eq(market_locations.first.name)
        expect(data.first[:bricks].size).to equal(1)
        expect(data.first[:bricks].first).to be_instance_of(BillingBrick)
      end
    end
  end

end
