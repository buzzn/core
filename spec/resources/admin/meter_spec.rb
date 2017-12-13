describe Meter::BaseResource do

  entity(:admin)     { Fabricate(:admin) }
  entity(:localpool) { create(:localpool) }
  entity!(:real)     { create(:meter, :real, group: localpool) }
  entity!(:virtual)  { create(:meter, :virtual, group: localpool) }

  let(:resources)    { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).meters }

  let(:base_keys) { ['id', 'type', 'updated_at',
                     'product_name',
                     'product_serialnumber',
                     'sequence_number',
                     'updatable',
                     'deletable'] }

  it 'retrieve' do
    [real, virtual].each do |meter|
      attrs = resources.retrieve(meter.id).to_h
      expect(attrs.keys & base_keys).to match_array base_keys
    end
  end

  it 'retrieve all - ids + types' do
    expected = [['meter_real', real.id]] + Meter::Virtual.all.collect do |v|
      ['meter_virtual', v.id]
    end
    result = resources.collect do |r|
      [r.type, r.id]
    end
    expect(result).to match_array expected
  end

  describe Meter::Real do

    it 'retrieve all - ids + types' do
      result = resources.select {|r| r.object.is_a?(Meter::Real)}
                 .collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['meter_real', real.id]]
    end

    it 'retrieve' do
      attrs = resources.retrieve(real.id).to_h
      expect(attrs['id']).to eq real.id
      expect(attrs['type']).to eq 'meter_real'
      expect(attrs.keys).to match_array base_keys + [
                                          'edifact_metering_type',
                                          'edifact_meter_size',
                                          'edifact_tariff',
                                          'edifact_measurement_method',
                                          'edifact_mounting_method',
                                          'edifact_voltage_level',
                                          'calibrated_until',
                                          'sent_data_dso',
                                          'edifact_cycle_interval',
                                          'edifact_data_logging',
                                          'ownership',
                                          'build_year',
                                          'manufacturer_name',
                                          'manufacturer_description',
                                          'location_description',
                                          'converter_constant',
                                          'direction_number',
                                          'data_source']
    end

  end

  describe Meter::Virtual do

    it 'retrieve all - ids + types' do
      expected = Meter::Virtual.all.collect do |v|
        ['meter_virtual', v.id]
      end
      result = resources.select {|r| r.object.is_a?(Meter::Virtual)}
                 .collect do |r|
        [r.type, r.id]
      end
      expect(result).to match_array expected
    end

    it 'retrieve' do
      attrs = resources.retrieve(virtual.id).to_h
      expect(attrs['id']).to eq virtual.id
      expect(attrs['type']).to eq 'meter_virtual'
      expect(attrs.keys).to match_array base_keys
    end
  end
end
