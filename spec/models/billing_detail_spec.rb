describe 'BillingDetail' do

  describe 'validity' do
    context 'reduced_power_factor too big' do
      it 'fails' do
        bd = BillingDetail.new
        bd.reduced_power_factor = 1.2
        expect {bd.save}.to raise_error ActiveRecord::StatementInvalid
      end
    end

    context 'reduced_power_factor negative' do
      it 'fails' do
        bd = BillingDetail.new
        bd.reduced_power_factor = -0.2
        expect {bd.save}.to raise_error ActiveRecord::StatementInvalid
      end
    end
  end

end
