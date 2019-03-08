describe ReadingResource do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

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

  context 'without a billing item' do
    it 'is ok' do
      expect(readingr.deletable).to eql true
    end
  end

  context 'with a billing item' do

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

    context 'open' do
      it 'is deletable' do
        expect(readingr.deletable).to eql true
      end
    end

    context 'void' do
      before do
        billing.status = 'void'
        billing.save
      end

      it 'is deletable' do
        expect(readingr.deletable).to eql true
      end
    end

    context 'documented' do
      before do
        billing.status = 'documented'
        billing.save
        readingr.object.reload
      end

      it 'is not deletable' do
        expect(readingr.deletable).to eql false
      end
    end

  end

end
