# coding: utf-8
describe Group::BaseResource do

  entity(:user) { Fabricate(:admin) }
  entity!(:tribe) { Fabricate(:tribe) }
  entity!(:localpool) { Fabricate(:localpool) }

  let(:base_attributes) { [:name,
                           :description,
                           :readable,
                           :registers,
                           :meters,
                           :managers,
                           :energy_producers,
                           :energy_consumers,
                           :updatable,
                           :deletable ] }

  it 'retrieve' do
    [tribe, localpool].each do |group|
      json = Group::BaseResource.retrieve(user, group.id).to_h
      expect(json.keys & base_attributes).to match_array base_attributes
    end
  end

  it 'retrieve - ids + types' do
    expected = {Group::Tribe => tribe.id, Group::Localpool => localpool.id}
    result = Group::BaseResource.all(user).collect do |r|
      [r.type.constantize, r.id]
    end
    expect(Hash[result]).to eq expected
  end

  describe 'scores' do

    entity(:group) { [tribe, localpool].sample }

    [:day, :month, :year].each do |interval|
      describe interval do

        before { Score.delete_all }

        [:sufficiency, :closeness, :autarchy, :fitting].each do |type|
        
          describe type do

            let!(:out_of_range) do
                begin
                  interval_information  = Group::Base.score_interval(interval.to_s, 123123)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let!(:in_range) do
                begin
                  interval_information  = Group::Base.score_interval(interval.to_s, Time.current.yesterday.to_i)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let(:attributes) { [:mode, :interval, :interval_beginning, :interval_end, :value] }
            it 'now' do
              result = Group::MinimalBaseResource
                         .retrieve(user, group.id)
                         .scores(interval: interval, mode: type)
              expect(result.size).to eq 1
              first = ScoreResource.send(:new, result.first)
              expect(first.to_hash.keys).to match_array attributes
            end

            it 'yesterday' do
              result = Group::MinimalBaseResource
                         .retrieve(user, group.id)
                         .scores(interval: interval,
                                 mode: type,
                                 timestamp: Time.current.yesterday)
              expect(result.size).to eq 1
              first = ScoreResource.send(:new, result.first)
              expect(first.to_hash.keys).to match_array attributes
            end

          end
        end
      end
    end

  end

  describe Group::Tribe do

    it 'retrieve all - ids + types' do
      result = Group::TribeResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Group::Tribe, tribe.id]]
    end

    it "retrieve - id + type" do
      [Group::BaseResource, Group::TribeResource].each do |type|
        json = type.retrieve(user, tribe.id).to_h
        expect(json[:id]).to eq tribe.id
        expect(json[:type]).to eq 'group_tribe'
      end
      expect{Group::TribeResource.retrieve(user, localpool.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'retrieve' do
      json = Group::BaseResource.retrieve(user, tribe.id).to_h
      expect(json.keys.size).to eq (base_attributes.size + 2)
    end

  end

  describe Group::Localpool do

    it 'retrieve all - ids + types' do
      expected = Group::Localpool.all.collect do |l|
        [Group::Localpool, l.id]
      end
      result = Group::LocalpoolResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result.sort).to eq expected.sort
    end

    it "retrieve - id + type" do
      [Group::BaseResource, Group::LocalpoolResource].each do |type|
        json = type.retrieve(user, localpool.id).to_h
        expect(json[:id]).to eq localpool.id
        expect(json[:type]).to eq 'group_localpool'
      end
      expect{Group::LocalpoolResource.retrieve(user, tribe.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'retrieve' do
      attributes = [:localpool_processing_contract,
                    :metering_point_operator_contract]
      json = Group::BaseResource.retrieve(user, localpool.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end

    it 'retrieve all prices' do
      attributes = [:name,
                    :baseprice_cents_per_month,
                    :energyprice_cents_per_kilowatt_hour,
                    :begin_date,
                    :id,
                    :type,
                    :updatable,
                    :deletable]
      Fabricate(:price, localpool: localpool)
      result = Group::LocalpoolResource.retrieve(user, localpool.id).prices
      expect(result.size).to eq 1
      first = PriceResource.send(:new, result.first)
      expect(first.to_hash.keys).to match_array attributes
    end

    it 'creates a new price' do
      group = Fabricate(:localpool)
      some_user = Fabricate(:user)

      request_params = {
        name: "special",
        begin_date: Date.new(2016, 1, 1),
        energyprice_cents_per_kilowatt_hour: 23.66,
        baseprice_cents_per_month: 500
      }

      expect{Group::LocalpoolResource.retrieve(some_user, group.id).create_price(request_params)}.to raise_error Buzzn::PermissionDenied
      expect(group.prices.size).to eq 0

      some_user.add_role(:manager, group)
      result = Group::LocalpoolResource.retrieve(some_user, group.id).create_price(request_params)
      expect(result.is_a?(PriceResource)).to eq true
      expect(result.object.localpool).to eq group
    end

    it 'creates a new billing cycle' do
      group = Fabricate(:localpool)
      some_user = Fabricate(:user)

      request_params = {
        name: 'abcd',
        begin_date: Date.new(2016, 1, 1),
        end_date: Date.new(2016, 9, 1)
      }

      expect{Group::LocalpoolResource.retrieve(some_user, group.id).create_billing_cycle(request_params)}.to raise_error Buzzn::PermissionDenied
      expect(group.billing_cycles.size).to eq 0

      some_user.add_role(:manager, group)
      result = Group::LocalpoolResource.retrieve(some_user, group.id).create_billing_cycle(request_params)
      expect(result.is_a?(BillingCycleResource)).to eq true
      expect(result.object.localpool).to eq group
    end

    xit 'retrieve all billing_cycles' do
      group = Fabricate(:localpool_sulz_with_registers_and_readings)
      some_user = Fabricate(:user)
      some_user.add_role(:manager, group)
      Fabricate(:billing_cycle, localpool: group)
      Fabricate(:billing_cycle, localpool: group)

      attributes = [:name,
                    :begin_date,
                    :end_date,
                    :id,
                    :type]

      result = Group::LocalpoolResource.retrieve(some_user, group.id).billing_cycles
      expect(result.size).to eq 2
      first = BillingCycleResource.send(:new, result.first)
      expect(first.to_hash.keys).to match_array attributes
    end
  end
end
