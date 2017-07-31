# coding: utf-8
describe Admin::LocalpoolResource do

  entity(:admin) { Fabricate(:admin) }
  entity!(:localpool) { Fabricate(:localpool) }

  let(:base_attributes) { ['id', 'type', 'updated_at',
                           'name',
                           'description',
                           'slug',
                           'updatable',
                           'deletable' ] }

  let(:resources) { Admin::LocalpoolResource.all(admin) }

  describe 'scores' do

    entity(:group) { localpool }

    [:day, :month, :year].each do |interval|
      describe interval do

        before { Score.delete_all }

        [:sufficiency, :closeness, :autarchy, :fitting].each do |type|

          describe type do

            let!(:out_of_range) do
                begin
                  interval_information = Buzzn::ScoreCalculator.new(nil, Time.new(123123)).send(:interval, interval)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let!(:in_range) do
                begin
                  interval_information = Buzzn::ScoreCalculator.new(nil, Time.current.yesterday).send(:interval, interval)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let(:attributes) { ['mode', 'interval', 'interval_beginning', 'interval_end', 'value'] }
            it 'now' do
              result = resources.retrieve(group.id)
                         .scores(interval: interval, mode: type)
              expect(result.size).to eq 1
              first = ScoreResource.send(:new, result.first)
              expect(first.to_hash.keys).to match_array attributes
            end

            it 'yesterday' do
              result = resources.retrieve(group.id)
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

  it 'retrieve all - ids + types' do
    expected = Group::Localpool.all.collect do |l|
      ['group_localpool', l.id]
    end
    result = resources.collect do |r|
      [r.type, r.id]
    end
    expect(result.sort).to eq expected.sort
  end

  it 'retrieve' do
    attributes = ['localpool_processing_contract',
                  'metering_point_operator_contract',
                  'localpool_power_taker_contracts',
                  'prices',
                  'admins',
                  'contracts',
                  'billing_cycles']
    attrs = resources.retrieve(localpool.id).to_h
    expect(attrs['id']).to eq localpool.id
    expect(attrs['type']).to eq 'group_localpool'
    expect(attrs.keys).to match_array base_attributes
  end

  context 'prices' do
    it 'retrieve all' do
      size = localpool.prices.size
      attributes = ['name',
                    'baseprice_cents_per_month',
                    'energyprice_cents_per_kilowatt_hour',
                    'begin_date',
                    'id',
                    'type',
                    'updated_at',
                    'updatable',
                    'deletable']
      Fabricate(:price, localpool: localpool)
      result = resources.retrieve(localpool.id).prices
      expect(result.size).to eq size + 1
      expect(result.first.to_hash.keys).to match_array attributes
    end

    it 'create' do
      request_params = {
        name: "special",
        begin_date: Date.new(2016, 1, 1),
        energyprice_cents_per_kilowatt_hour: 23.66,
        baseprice_cents_per_month: 500
      }

      result = resources.retrieve(localpool.id).create_price(request_params)
      expect(result.is_a?(Admin::PriceResource)).to eq true
      expect(result.object.localpool).to eq localpool
    end
  end

  context 'billing cycles' do
    it 'create' do
      request_params = {
        name: 'abcd',
        begin_date: Date.new(2016, 1, 1),
        end_date: Date.new(2016, 9, 1)
      }

      result = resources.retrieve(localpool.id).create_billing_cycle(request_params)
      expect(result.is_a?(Admin::BillingCycleResource)).to eq true
      expect(result.object.localpool).to eq localpool
    end

    it 'retrieve all' do
      size = localpool.billing_cycles.size
      Fabricate(:billing_cycle, localpool: localpool)
      Fabricate(:billing_cycle, localpool: localpool)

      attributes = ['name',
                    'begin_date',
                    'end_date',
                    'id',
                    'type',
                    'updated_at']

      result = resources.retrieve(localpool.id).billing_cycles
      expect(result.size).to eq size + 2
      expect(result.first.to_hash.keys).to match_array attributes
    end
  end
end
