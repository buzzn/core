require 'buzzn/score_calculator'

describe Buzzn::ScoreCalculator do

  let(:group) { Fabricate(:group) }
  let(:now) { Time.find_zone('Berlin').local(2016,2,2, 1,30,1) }

  subject do
    scores = Buzzn::ScoreCalculator.new(group, now.to_i)
    scores
  end

  [:day_interval, :month_interval, :year_interval].each do |interval|
    [:create_autarchy_score, :create_fitting_score, :create_closeness_score,
     :create_sufficiency_score].each do |type|
      it "#{type.to_s.gsub(/_/, ' ')} for #{interval.to_s.gsub(/_/, ' ')}" do
        value = (rand * 6).to_i
        # both are private methods
        time_interval = subject.send(interval)
        subject.send(type, time_interval, value)

        last = Score.last
        expect(last.scoreable).to eq group
        expect(last.value).to eq value
        expect(last.interval).to eq interval.to_s.sub('_interval', '')
        expect(last.interval_beginning).to eq time_interval[1]
        # there is a micro-second difference
        expect(last.interval_end.to_i).to eq time_interval[2].to_i
      end
    end
  end

  describe 'for new group' do

    before do
      Timecop.freeze(now)
      subject.instance_variable_set(:@data_in, [])
      subject.instance_variable_set(:@data_out, [])
    end

    after do
      Timecop.return
    end

    it 'calculates autarchy' do
      subject.calculate_autarchy_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 0.0
        expect(score.mode).to eq 'autarchy'
      end
    end

    it 'calculates fitting' do
      subject.calculate_fitting_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 0.0
        expect(score.mode).to eq 'fitting'
      end
    end

    it 'calculates sufficiency' do
      subject.calculate_sufficiency_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 0.0
        expect(score.mode).to eq 'sufficiency'
      end
    end

    it 'calculates closeness now' do
      subject.calculate_closeness_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq -1.0
        expect(score.mode).to eq 'closeness'
      end
    end

    it 'calculates closeness in the past' do
      time = Time.find_zone('Berlin').local(2012,2,1, 1,30,1)
      subject.instance_variable_set(:@now, time)
      Timecop.freeze(time)
      subject.calculate_closeness_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 0.0
        expect(score.mode).to eq 'closeness'
      end
    end
  end

  describe 'group with energy-consumer, MPs. etc and one sample' do

    let(:group) do
      group         = Fabricate(:group)
      user          = Fabricate(:user)
      consumer      = Fabricate(:user)
      producer      = Fabricate(:user)
      mp_in         = Fabricate(:metering_point, mode: 'in')
      mp_out        = Fabricate(:metering_point, mode: 'out')

      group.metering_points += [mp_in, mp_out]
      consumer.add_role(:member, mp_out)

      group
    end

    before do
      Timecop.freeze(now)
      subject.instance_variable_set(:@data_in,
                                    [ { power_milliwatt: 1000000 },
                                      { power_milliwatt: 1200000 },
                                      { power_milliwatt: 900000 },
                                      { power_milliwatt: 0 } ] )
      subject.instance_variable_set(:@data_out,
                                    [ { power_milliwatt: 800000 },
                                      { power_milliwatt: 1300000 },
                                      { power_milliwatt: 1000000 } ] )
    end

    after do
      Timecop.return
    end

    it 'calculates fitting' do
      subject.calculate_fitting_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 2.0
        expect(score.mode).to eq 'fitting'
      end
    end

    it 'calculates autarchy' do
      subject.calculate_autarchy_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 5.0
        expect(score.mode).to eq 'autarchy'
      end
    end

    it 'calculates sufficiency' do
      subject.calculate_sufficiency_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 1.0
        expect(score.mode).to eq 'sufficiency'
      end
    end

  end

  describe 'group Home-Of-The-Brave' do
    let(:now) { Time.find_zone('Berlin').local(2016,10,5, 18,30,1)  }
    let(:group) do
      Fabricate(:buzzn_metering)
      easymeter_60051599 = Fabricate(:easymeter_60051599)
      mp_z2 = easymeter_60051599.metering_points.first
      easymeter_60051559 = Fabricate(:easymeter_60051559)
      mp_z3 = easymeter_60051559.metering_points.first
      easymeter_60051560 = Fabricate(:easymeter_60051560)
      mp_z4 = easymeter_60051560.metering_points.first
      group = Fabricate(:group_home_of_the_brave,
                        metering_points: [mp_z2, mp_z3, mp_z4])
      consumer = Fabricate(:user)
      consumer.add_role(:member, mp_z2)
      group
    end

    it 'calculates autarchy' do |spec|
      VCR.use_cassette("lib/#{spec.metadata[:description].downcase}") do
        subject.calculate_autarchy_scores
        expect(Score.count).to eq 3
        Score.all.each do |score|
          expect(score.value).to eq 5.0
          expect(score.mode).to eq 'autarchy'
        end
      end
    end

    it 'calculates sufficiency' do |spec|
      VCR.use_cassette("lib/#{spec.metadata[:description].downcase}") do
        subject.calculate_sufficiency_scores
        expect(Score.count).to eq 3
        Score.all.each do |score|
          expect(score.value).to eq 1.0
          expect(score.mode).to eq 'sufficiency'
        end
      end
    end

    it 'calculates fitting' do |spec|
      VCR.use_cassette("lib/#{spec.metadata[:description].downcase}") do
        subject.calculate_fitting_scores
        expect(Score.count).to eq 3
        Score.all.each do |score|
          expect(score.value).to eq 1.0
          expect(score.mode).to eq 'fitting'
        end
      end
    end

    it 'calculates closeness' do
      subject.calculate_closeness_scores
      expect(Score.count).to eq 3
      Score.all.each do |score|
        expect(score.value).to eq 0.0
        expect(score.mode).to eq 'closeness'
      end
    end


  end
end
