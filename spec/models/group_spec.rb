# coding: utf-8
describe "Group Model" do

  entity(:wagnis4) { Fabricate(:localpool_wagnis4) }
  entity(:butenland) { Fabricate(:tribe_hof_butenland) }
  entity(:karin) { Fabricate(:tribe_karins_pv_strom) }
  entity(:home_of_the_brave) {Fabricate(:localpool_home_of_the_brave) }
  entity(:localpool) { Fabricate(:localpool) }
  entity(:user) { Fabricate(:user) }
  entity(:admin) { Fabricate(:admin) }

  it 'filters group', retry: 3 do
    group = home_of_the_brave

    [group.name, group.description].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        groups = Group::Base.filter(value)
        expect(groups).to include group
      end
    end
  end


  it 'can not find anything' do
    groups = Group::Base.filter('Der Clown ist müde und geht nach Hause.')
    expect(groups.size).to eq 0
  end


  it 'filters group with no params' do
    groups = Group::Base.filter(nil)
    expect(groups.size).to eq Group::Base.count
  end

  it 'limits readable_by' do
    wagnis4.update(readable: 'world')
    butenland.update(readable: 'community')
    karin.update(readable: 'friends')
    tribe     = Fabricate(:tribe_with_members_readable_by_world, readable: 'members')
    manager   = Fabricate(:user)
    manager.add_role(:manager, karin)

    groups = Group::Base.readable_by(nil)
    expect(groups).to include wagnis4
    expect(groups).not_to include butenland
    expect(groups).not_to include karin
    expect(groups).not_to include tribe

    groups = Group::Base.readable_by(user)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).not_to include karin
    expect(groups).not_to include tribe

    groups = Group::Base.readable_by(admin)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).to include karin
    expect(groups).to include tribe

    groups = Group::Base.readable_by(tribe.members.first)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).not_to include karin
    expect(groups).to include tribe

    groups = Group::Base.readable_by(karin.managers.first)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).to include karin
    expect(groups).not_to include tribe

    manager.friends << Fabricate(:user)
    groups = Group::Base.readable_by(karin.managers.first.friends.first)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).to include karin
    expect(groups).not_to include tribe

    manager.add_role(:manager, tribe)
    groups = Group::Base.readable_by(tribe.managers.first.friends.first)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).to include karin
    expect(groups).not_to include tribe

    friend = Fabricate(:user)
    tribe.members.first.friends << friend
    groups = Group::Base.readable_by(friend)
    expect(groups).to include wagnis4
    expect(groups).to include butenland
    expect(groups).not_to include karin
    expect(groups).not_to include tribe
  end

  it 'selects the energy producers/consumers and involved users of a tribe' do
    tribe         = Fabricate(:tribe)
    user          = Fabricate(:user)
    consumer      = Fabricate(:user)
    producer      = Fabricate(:user)
    register_in   = Fabricate(:input_register, meter: Fabricate(:meter))
    register_out  = Fabricate(:output_register, meter: Fabricate(:meter))

    tribe.registers += [register_in, register_out]

    expect(tribe.energy_producers).to match_array []
    expect(tribe.energy_consumers).to match_array []
    expect(tribe.involved).to match_array []

    producer.add_role(:manager, register_out)
    expect(tribe.energy_producers).to match_array [producer]
    expect(tribe.energy_consumers).to match_array []
    expect(tribe.involved).to match_array [producer]

    consumer.add_role(:member, register_in)
    expect(tribe.energy_producers).to match_array [producer]
    expect(tribe.energy_consumers).to match_array [consumer]
    expect(tribe.involved).to match_array [producer, consumer]

    consumer.add_role(:member, register_out)
    producer.add_role(:member, register_in)
    expect(tribe.energy_producers).to match_array [producer, consumer]
    expect(tribe.energy_consumers).to match_array [consumer, producer]
    expect(tribe.involved).to match_array [producer, consumer]

    user.add_role(:member, register_out)
    expect(tribe.energy_producers).to match_array [user, producer, consumer]
    expect(tribe.energy_consumers).to match_array [consumer, producer]
    expect(tribe.involved).to match_array [producer, consumer, user]

    user.add_role(:manager, register_in)
    expect(tribe.energy_producers).to match_array [user, producer, consumer]
    expect(tribe.energy_consumers).to match_array [user, consumer, producer]
    expect(tribe.involved).to match_array [producer, consumer, user]
  end

  it 'calculates its scores on given group' do
    tribe = Fabricate(:tribe)
    tribe.calculate_scores(Time.find_zone('Berlin').local(2016,2,2, 1,30,1))

    expect(Score.count).to eq 12
  end


  it 'get a metering_point_operator_contract from localpool' do
    localpool  = Fabricate(:metering_point_operator_contract_of_localpool).localpool
    expect(localpool.metering_point_operator_contract).to be_a Contract::MeteringPointOperator
  end

  it 'get a localpool_processing_contract from localpool' do
    localpool  = Fabricate(:localpool_processing_contract).localpool
    expect(localpool.localpool_processing_contract).to be_a Contract::LocalpoolProcessing
  end

  it 'calculates scores of all groups via sidekiq' do
    expect {
      Group::Base.calculate_scores
    }.to change(CalculateGroupScoresWorker.jobs, :size).by(1)
  end

  it 'adds multiple addresses to localpool' do
    group = wagnis4
    main_address = Fabricate(:address, city: 'Berlin', created_at: Time.now - 1.year)
    group.addresses << main_address
    secondary_address = Fabricate(:address, city: 'München')
    group.addresses << secondary_address

    expect(group.main_address.city).to eq main_address.city

    secondary_address.update_column(:created_at, Time.now - 2.years)

    expect(group.main_address.city).to eq secondary_address.city
  end

  describe Group::Localpool do
    it 'creates corrected ÜGZ registers' do
      localpool = Fabricate(:localpool)
      expect(localpool.registers.by_label(Register::Base::GRID_CONSUMPTION_CORRECTED).size).to eq 1
      expect(localpool.registers.by_label(Register::Base::GRID_FEEDING_CORRECTED).size).to eq 1
    end
  end
end
