describe Buzzn::ScoreCalculator do

  entity(:group) { Fabricate(:tribe) }
  let(:now) { Time.find_zone('Berlin').local(2016,2,2, 1,30,1) }

  subject do
    Buzzn::ScoreCalculator.new(group, now)
  end

  before do
    Score.delete_all
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

    entity(:group2) do
      group         = Fabricate(:tribe)
      register_in   = Fabricate(:input_meter).input_register
      register_out  = Fabricate(:output_meter).output_register

      group.registers += [register_in, register_out]

      group
    end

    subject do
      Buzzn::ScoreCalculator.new(group2, now)
    end

    before do
      Timecop.freeze(now)

      result_out = Buzzn::DataResultSet.milliwatt("no-id-needed")
      result_out.add(Time.at(Time.now.beginning_of_day.to_i), 1000000, 'out')
      result_out.add(Time.at((Time.now.beginning_of_day + 15.minutes).to_i), 1200000, 'out')
      result_out.add(Time.at((Time.now.beginning_of_day + 30.minutes).to_i), 900000, 'out')
      result_out.add(Time.at((Time.now.beginning_of_day + 45.minutes).to_i), 0, 'out')

      result_in = Buzzn::DataResultSet.milliwatt("no-id-needed")
      result_in.add(Time.at(Time.now.beginning_of_day.to_i), 800000, 'in')
      result_in.add(Time.at((Time.now.beginning_of_day + 15.minutes).to_i), 1300000, 'in')
      result_in.add(Time.at((Time.now.beginning_of_day + 30.minutes).to_i), 1000000, 'in')

      subject.instance_variable_set(:@data_out, result_out.out)
      subject.instance_variable_set(:@data_in, result_in.in)
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

    class DiscovergyBroker
      def validates_credentials
      end
    end

    let(:now) { Time.find_zone('Berlin').local(2016,10,5, 18,30,1)  }
    entity(:group3) do
      easymeter_60051599 = Fabricate(:easymeter_60051599)
      easymeter_60051599.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051599", resource: easymeter_60051599)
      register_z2 = easymeter_60051599.registers.first
      easymeter_60051559 = Fabricate(:easymeter_60051559)
      easymeter_60051559.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_60051559", resource: easymeter_60051559)
      register_z3 = easymeter_60051559.registers.first
      easymeter_60051560 = Fabricate(:easymeter_60051560)
      easymeter_60051560.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051560", resource: easymeter_60051560)
      register_z4 = easymeter_60051560.registers.first
      group = Fabricate(:localpool_home_of_the_brave, registers: [register_z2, register_z3, register_z4])
      group
    end

    subject do
      Buzzn::ScoreCalculator.new(group3, now)
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
          expect(score.value).to eq 5.0
          expect(score.mode).to eq 'sufficiency'
        end
      end
    end

    it 'calculates fitting' do |spec|
      VCR.use_cassette("lib/#{spec.metadata[:description].downcase}") do
        subject.calculate_fitting_scores
        expect(Score.count).to eq 3
        Score.all.each do |score|
          expect(score.value).to eq 5.0
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
