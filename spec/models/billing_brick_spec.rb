describe 'BillingBrick' do

  it 'can be initialized with values' do
    attrs = { status: :open, type: :mickey, start_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 12, 31) }
    brick = BillingBrick.new(attrs)
    attrs.each { |key, value| expect(brick.send(key)).to equal(value) }
  end

end
