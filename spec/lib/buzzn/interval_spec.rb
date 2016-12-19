describe Buzzn::Interval do

  let(:durations) { [:hour, :day, :month, :year] }

  subject { Buzzn::Interval }

  [:hour, :day, :month, :year].each do |duration|
    it "creates a #{duration}" do
      interval = subject.send(duration, Time.now)
      durations.each do |d|
        expect(interval.send(:"#{d}?")).to eq d == duration
      end
      expect(interval.from).to eq(subject.send(duration, interval.from).from)
      expect(interval.to).to eq(subject.send(duration, interval.from).to)
      expect(interval.from).to eq(subject.send(duration, interval.to - 1.second).from)
      expect(interval.to).to eq(subject.send(duration, interval.to - 1.second).to)
    end
  end

end
