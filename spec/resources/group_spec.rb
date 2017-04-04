# coding: utf-8
describe Group::BaseResource do

  let(:user) { Fabricate(:admin) }
  let!(:tribe) { Fabricate(:tribe) }
  let!(:localpool) { Fabricate(:localpool) }

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

  it 'has all attributes' do
    [tribe, localpool].each do |group|
      json = Group::BaseResource.retrieve(user, group.id).to_h
      expect(json.keys & base_attributes).to match_array base_attributes
    end
  end

  it 'collects with right ids + types' do
    expected = {Group::Tribe => tribe.id, Group::Localpool => localpool.id}
    result = Group::BaseResource.all(user).collect do |r|
      [r.type.constantize, r.id]
    end
    expect(Hash[result]).to eq expected
  end

  describe 'scores' do

    let(:group) { [tribe, localpool].sample }

    [:day, :month, :year].each do |interval|
      [:sufficiency, :closeness, :autarchy, :fitting].each do |type|
        describe interval do
          describe type do

            let!(:out_of_range) do
              interval_information  = Group::Base.score_interval(interval.to_s, 123123)
              Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
            end

            let!(:in_range) do
              interval_information  = Group::Base.score_interval(interval.to_s, Time.current.yesterday.to_i)
              Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
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

    it 'collects with right ids + types' do
      result = Group::TribeResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Group::Tribe, tribe.id]]
    end

    it "correct id + type" do
      [Group::BaseResource, Group::TribeResource].each do |type|
        json = type.retrieve(user, tribe.id).to_h
        expect(json[:id]).to eq tribe.id
        expect(json[:type]).to eq 'group_tribe'
      end
      expect{Group::TribeResource.retrieve(user, localpool.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'has all attributes' do
      json = Group::BaseResource.retrieve(user, tribe.id).to_h
      expect(json.keys.size).to eq (base_attributes.size + 2)
    end

  end

  describe Group::Localpool do
  
    it 'collects with right ids + types' do
      expected = [Group::Localpool, localpool.id]
      result = Group::LocalpoolResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [expected]
    end

    it "correct id + type" do
      [Group::BaseResource, Group::LocalpoolResource].each do |type|
        json = type.retrieve(user, localpool.id).to_h
        expect(json[:id]).to eq localpool.id
        expect(json[:type]).to eq 'group_localpool'
      end
      expect{Group::LocalpoolResource.retrieve(user, tribe.id)}.to raise_error Buzzn::RecordNotFound
    end
      
    it 'has all attributes' do
      attributes = [:localpool_processing_contract,
                    :metering_point_operator_contract]
      json = Group::BaseResource.retrieve(user, localpool.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end
  end
end
