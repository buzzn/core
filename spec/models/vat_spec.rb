describe Vat do
  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
    create(:vat, amount: 0.19, begin_date: Date.new(2004, 4, 1))
    create(:vat, amount: 0.19, begin_date: Date.new(2007, 7, 1))
  end

  let!(:current) do
    create(:vat, amount: 0.19, begin_date: Date.new(2020, 2, 1))
  end

  it 'current' do
    expect(Vat.current).to eq(current);
  end
end