require_relative 'api_mock'

describe Services::Datasource::Discovergy::OptimizedGroup do

  def serialized_meter(serial, type)
      {
        serialNumber: serial,
        # discovergy does create such a location for virtual meters
        # location: { street: "Virtual", streetNumber: "0", zip: "", city: "Virtual", country: "DE"},
        location: { street: "Forst Weg", streetNumber: "1", zip: "12065", city: "Brunn", country: "DE"},
        administrationNumber: "",
        type: type,
        measurementType: "ELECTRICITY",
        scalingFactor: 1,
        currentScalingFactor: 1,
        voltageScalingFactor: 1,
        internalMeters: 1,
        firstMeasurementTime: 1453902166771,
        lastMeasurementTime: 1513098129911
      }
  end

  let(:info_result) do
    [
      serialized_meter("1234567890", "EASYMETER"),
      serialized_meter("9876543210", "EASYMETER"),
    ]
  end

  let(:create_result) do
    serialized_meter("00000104", "VIRTUAL")
  end

  class ApiMock

    attr_writer :result
    attr_reader :query

    def request(query, *)
      @query = query.to_uri('')
      case @result
      when Array then @result.collect { |r| OpenStruct.new(r) }
      when String then ''
      else OpenStruct.new(@result)
      end
    end
  end

  entity(:api) { ApiMock.new }

  entity(:optimized_group) do
    Services::Datasource::Discovergy::OptimizedGroup.new(api: api)
  end

  entity(:localpool) { create(:localpool) }

  entity!(:meters) do
    create(:meter, :real, :with_broker, group: localpool,
           product_serialnumber: '1234567890')
    meter = create(:meter, :real, :with_broker, register_direction: :output, group: localpool,
                   product_serialnumber: '9876543210')
    meter.registers.first.production_pv!
    localpool.meters
  end

  context 'verifies' do

    before do
      Meter::Discovergy.delete_all
      Broker::Discovergy.create(meter: Meter::Discovergy.create(group: localpool, product_serialnumber: '0000000'))
    end

    it 'succeeds' do
      api.result = info_result
      result = optimized_group.verify(localpool)
      # the created meter and the info_result have the same serial_number
      expect(result).to eq true
      expect(api.query).to eq '/virtual_meter?meterId=VIRTUAL_0000000'
    end

    it 'fails' do
      api.result = []
      result = optimized_group.verify(localpool)
      expect(result).to eq false
      expect(api.query).to eq '/virtual_meter?meterId=VIRTUAL_0000000'
    end
  end

  context 'create' do

    before { Meter::Discovergy.delete_all }

    it 'succeeds' do
      api.result = create_result
      meter = optimized_group.create(localpool)
      expect(meter.broker.external_id).to eq 'VIRTUAL_00000104'
      expect(meter).to be_a ::Meter::Discovergy
      expect(meter.group).to eq localpool
      expect(api.query).to eq '/virtual_meter?meterIdsPlus=EASYMETER_9876543210&meterIdsMinus=EASYMETER_1234567890'
    end
  end

  context 'delete' do
    before do
      Meter::Discovergy.delete_all
      Broker::Discovergy.create(meter: Meter::Discovergy.create(group: localpool, product_serialnumber: '0101010'))
    end

    it 'succeeds' do
      api.result = ''
      expect(Meter::Discovergy.count).to eq 1
      optimized_group.delete(localpool)
      expect(Meter::Discovergy.count).to eq 0
      expect(api.query).to eq '/virtual_meter?meterId=VIRTUAL_0101010'
    end
  end
end
