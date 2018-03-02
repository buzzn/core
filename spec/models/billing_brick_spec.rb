describe 'BillingBrick' do

  describe 'new' do
    it 'can be initialized with a date range' do
      attrs = { status: 'closed', contract_type: 'gap', date_range: Date.new(2018, 1, 1)...Date.new(2019, 1, 1) }
      brick = BillingBrick.new(attrs)
      attrs.each { |key, value| expect(brick.send(key)).to eq(value) }
      expect(brick.begin_date).to eq(attrs[:date_range].first)
      expect(brick.end_date).to eq(attrs[:date_range].last)
    end
    it 'can be initialized with begin and end dates' do
      attrs = { status: 'closed', contract_type: 'gap', begin_date: Date.new(2018, 1, 1), end_date: Date.new(2019, 1, 1) }
      brick = BillingBrick.new(attrs)
      attrs.each { |key, value| expect(brick.send(key)).to eq(value) }
      expect(brick.date_range).to eq(attrs[:begin_date]...attrs[:end_date])
    end
  end

end
