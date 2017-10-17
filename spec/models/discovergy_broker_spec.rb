
describe "DiscovergyBroker Model" do

  entity(:in_meter) { Fabricate(:input_meter) }
  entity(:out_meter) { Fabricate(:easymeter_60051560) }
  entity(:two_way_meter_with_registers) { Fabricate(:easymeter_60139082) }
  entity(:group) { Fabricate(:tribe) }

  it "creates broker for one way in meter" do
    count = Broker::Discovergy.count
    meter = in_meter
    Broker::Discovergy.create!(
      mode: :in,
      external_id: 'EASYMETER_60139082',
      provider_login: 'team@localpool.de',
      provider_password: 'Zebulon_4711',
      resource: meter
    )
    expect(Broker::Discovergy.all.size).to eq count + 1
  end

  it "creates broker for one way out meter" do
    count = Broker::Discovergy.count
    meter = out_meter
    Broker::Discovergy.create!(
      mode: :out,
      external_id: 'EASYMETER_60139082',
      provider_login: 'team@localpool.de',
      provider_password: 'Zebulon_4711',
      resource: meter
    )
    expect(Broker::Discovergy.all.size).to eq count + 1
  end

  it "creates in and out broker for group" do
    count = Broker::Discovergy.count
    Broker::Discovergy.create!(
      mode: :in,
      external_id: 'VIRTUAL_12345678',
      provider_login: 'team@localpool.de',
      provider_password: 'Zebulon_4711',
      resource: group
    )
    Broker::Discovergy.create!(
      mode: :out,
      external_id: 'VIRTUAL_87654321',
      provider_login: 'team@localpool.de',
      provider_password: 'Zebulon_4711',
      resource: group
    )
    expect(group.brokers.size).to eq 2
    expect(Broker::Discovergy.all.size).to eq count + 2
  end

  it 'creates broker for two way meter' do
    count = Broker::Discovergy.count
    meter = two_way_meter_with_registers
    Broker::Discovergy.create!(
      mode: :in_out,
      external_id: 'EASYMETER_60139082',
      provider_login: 'team@localpool.de',
      provider_password: 'Zebulon_4711',
      resource: meter
    )
    expect(Broker::Discovergy.all.size).to eq count + 1
  end

  it 'does not create broker: wrong in-mode for two way meter' do
    meter = two_way_meter_with_registers

    expect{
      Broker::Discovergy.create!(
        mode: :in,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: meter
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: wrong out-mode for two way meter' do
    meter = two_way_meter_with_registers

    expect{
      Broker::Discovergy.create!(
        mode: :out,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: meter
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: missing external_id' do
    meter = two_way_meter_with_registers

    expect{
      Broker::Discovergy.create!(
        mode: :in_out,
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: meter
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: wrong in_out-mode for group broker' do
    expect{
      Broker::Discovergy.create!(
        mode: :in_out,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: group
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: wrong virtual-mode for group broker' do
    expect{
      Broker::Discovergy.create!(
        mode: :virtual,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: group
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: missing provider_login' do
    meter = two_way_meter_with_registers

    expect{
      Broker::Discovergy.create!(
        mode: :in,
        external_id: 'EASYMETER_60139082',
        provider_password: 'Zebulon_4711',
        resource: group
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: missing provider_password' do
    expect{
      Broker::Discovergy.create!(
        mode: :in,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        resource: group
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: invalid mode' do
    expect{
      Broker::Discovergy.create!(
        mode: :not_working,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: group
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: wrong in-mode for out meter' do
    expect{
      Broker::Discovergy.create!(
        mode: :in,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: out_meter
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: wrong out-mode for in meter' do
    expect{
      Broker::Discovergy.create!(
        mode: :out,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: in_meter
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'does not create broker: missing resource' do
    meter = two_way_meter_with_registers

    expect{
      Broker::Discovergy.create!(
        mode: :in,
        external_id: 'EASYMETER_60139082',
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end
end
