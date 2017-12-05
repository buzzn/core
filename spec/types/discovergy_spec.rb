require 'buzzn/types/discovergy'

describe Types::Discovergy do

  let(:base) { 'http://example.com' }
  entity(:meter) do
    meter = create(:meter, :real)
    create(:broker, :discovergy, meter: meter)
    meter
  end

  it Types::Discovergy::Meters do
    subject = Types::Discovergy::Meters::Get.new
    expect(subject.http_method).to eq :get
    expect(subject.to_uri(base)).to eq "#{base}/meters"
  end

  it Types::Discovergy::FieldNames do
    subject = Types::Discovergy::FieldNames::Get.new(meter: meter)
    expect(subject.http_method).to eq :get
    expect(subject.to_uri(base)).to eq "#{base}/field_names?meterId=#{meter.broker.external_id}"
  end

  context Types::Discovergy::LastReading do
    it 'minimal' do
      subject = Types::Discovergy::LastReading::Get.new(meter: meter, fields: [:power])
      expect(subject.http_method).to eq :get
      expect(subject.to_uri(base)).to eq "#{base}/last_reading?meterId=#{meter.broker.external_id}&fields=power"
    end

    it 'full' do
      subject = Types::Discovergy::LastReading::Get.new(meter: meter,
                                                        fields: [:power],
                                                        each: true)
      expect(subject.http_method).to eq :get
      expect(subject.to_uri(base)).to eq "#{base}/last_reading?meterId=#{meter.broker.external_id}&fields=power&each=true"
    end
  end

  context Types::Discovergy::Readings do
    it 'minimal' do
      subject = Types::Discovergy::Readings::Get.new(meter: meter,
                                                     fields: [:energy],
                                                     from: 0)
      expect(subject.http_method).to eq :get
      expect(subject.to_uri(base)).to eq "#{base}/readings?meterId=#{meter.broker.external_id}&fields=energy&from=0"
    end

    it 'full' do
      subject = Types::Discovergy::Readings::Get.new(meter: meter,
                                                     fields: [:energyOut],
                                                     from: 0,
                                                     to: 123,
                                                     resolution: :one_day,
                                                     disaggregation: false)
      expect(subject.http_method).to eq :get
      expect(subject.to_uri(base)).to eq "#{base}/readings?meterId=#{meter.broker.external_id}&fields=energyOut&from=0&to=123&resolution=one_day&disaggregation=false"
    end
  end

  context Types::Discovergy::VirtualMeter do

    it 'GET' do
      subject = Types::Discovergy::VirtualMeter::Get.new(meter: meter)
      expect(subject.http_method).to eq :get
      expect(subject.to_uri(base)).to eq "#{base}/virtual_meter?meterId=#{meter.broker.external_id}"
    end

    context 'POST' do
      it 'minimal' do
        subject = Types::Discovergy::VirtualMeter::Post.new(meter: meter,
                                                        meter_ids_plus: [])
        expect(subject.http_method).to eq :post
        expect(subject.to_uri(base)).to eq "#{base}/virtual_meter?meterId=#{meter.broker.external_id}&meterIdsPlus="
      end

      it 'full' do
        subject = Types::Discovergy::VirtualMeter::Post.new(meter: meter,
                                                        meter_ids_plus: [],
                                                        meter_ids_minus: [])
        expect(subject.http_method).to eq :post
        expect(subject.to_uri(base)).to eq "#{base}/virtual_meter?meterId=#{meter.broker.external_id}&meterIdsPlus=&meterIdsMinus="
      end
    end

    it 'DELETE' do
      subject = Types::Discovergy::VirtualMeter::Delete.new(meter: meter)
      expect(subject.http_method).to eq :delete
      expect(subject.to_uri(base)).to eq "#{base}/virtual_meter?meterId=#{meter.broker.external_id}"
    end
  end
end
