describe "billing-cycles" do

  let(:group) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  let(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }

  it 'creates all regular billings' do

  end

end