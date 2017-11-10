describe "Organization Market Function model" do

  let(:record) { create(:organization_market_function, function: :power_giver) }

  it "stores function correctly" do
    expect(record.reload.function).to eq("power_giver")
  end

  it "only allows known function types" do
    expect { build(:organization_market_function, function: :fritz) }.to raise_error(ArgumentError)
  end
end
