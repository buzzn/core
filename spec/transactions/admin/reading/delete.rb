
describe Transactions::Admin::Reading::Delete do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:meter) do
    create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
  end

  let(:registerr) do
    localpoolr.meters.retrieve(meter.id).registers.first
  end

  let(:register) do
    registerr.object
  end

  let(:reading) do
    create(:reading, register: register, raw_value: 42, date: Date.new(2019, 3, 8))
  end

  let(:readingr) do
    registerr.readings.retrieve(reading.id)
  end

  let(:billing) do
    create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
  end

  let(:result) do
    Transactions::Admin::Reading::Delete.new.(resource: readingr)
  end

  context 'without a billing item' do

    it 'deletes' do
      expect(result).to be_success
    end

  end

  context 'with a billing item' do

    [[:open, true],
     [:calculated, false],
     [:documented, false],
     [:void, true]].each do |status|
      context status.first.to_s do
        before do
          billing.status = status.first.to_s
          billing.save
        end

        context 'as a begin_reading' do

          let(:another_reading) do
            create(:reading, register: register, raw_value: 42, date: Date.new(2019, 3, 10))
          end
          let!(:billing_item) do
            create(:billing_item,
                   begin_date: Date.new(2019, 3, 8),
                   end_date: Date.new(2019, 3, 10),
                   billing: billing,
                   begin_reading: reading,
                   end_reading: another_reading)
          end

          it "does#{status.last ? '' : 'not'} delete" do
            if status.last
              expect(result).to be_success
            else
              expect {result}.to raise_error Buzzn::ValidationError, '{:billing_items=>["reading is used in at least one calculated billing"]}'
            end
          end
        end

        context 'as an end_reading' do
          let(:another_reading) do
            create(:reading, register: register, raw_value: 42, date: Date.new(2019, 3, 3))
          end

          let!(:billing_item) do
            create(:billing_item,
                   begin_date: Date.new(2019, 3, 3),
                   end_date: Date.new(2019, 3, 8),
                   billing: billing,
                   begin_reading: another_reading,
                   end_reading: reading)
          end

          it "does#{status.last ? '' : 'not'} delete" do
            if status.last
              expect(result).to be_success
            else
              expect {result}.to raise_error Buzzn::ValidationError, '{:billing_items=>["reading is used in at least one calculated billing"]}'
            end
          end

        end
      end
    end
  end
end
