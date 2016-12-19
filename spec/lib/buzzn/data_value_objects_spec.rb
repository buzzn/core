describe Buzzn::DataPoint do

  subject { Buzzn::DataPoint }

  it 'loads it hash representation' do
    reference = subject.new(Time.new(123456789), 987654331)
    other = subject.from_hash(reference.to_hash)
    expect(reference.timestamp).to eq other.timestamp
    expect(reference.value).to eq other.value
  end

  it 'round-trip via json' do
    reference = subject.new(Time.new(123456789), 987654331)
    other = subject.from_json(reference.to_hash.to_json)
    expect(reference.timestamp).to eq other.timestamp
    expect(reference.value).to eq other.value
  end

  it 'adds value if timestamp match' do
    reference = subject.new(Time.new(123456789), 987654331)
    other = subject.new(Time.new(123456789), 1)
    reference.add(other)

    expect(reference.value).to eq 987654332

    expect { reference.add(subject.new(Time.new(1), 0)) }.to raise_error ArgumentError
  end
end

describe Buzzn::DataResult do

  subject { Buzzn::DataResult }

  it 'loads it hash representation' do
    reference = subject.new(Time.new(123456789), 987654331,
                            'u-i-d',[:in, :out].sample,
                            Time.current.to_f)
    other = subject.from_hash(reference.to_hash)
    expect(reference.resource_id).to eq other.resource_id
    expect(reference.mode).to eq other.mode
    expect(reference.timestamp).to eq other.timestamp
    expect(reference.value).to eq other.value
  end

  it 'round-trip via json' do
    reference = subject.new(Time.new(123456789), 987654331,
                            'u-i-d',[:in, :out].sample,
                            Time.current.to_f)
    other = subject.from_json(reference.to_json)
    expect(reference.resource_id).to eq other.resource_id
    expect(reference.mode).to eq other.mode
    expect(reference.timestamp).to eq other.timestamp
    expect(reference.value).to eq other.value
  end
end

describe Buzzn::InOutDataResults do

  subject { Buzzn::InOutDataResults }

  it 'loads it hash representation' do
    reference = subject.new(Time.new(123456789), 987654331,
                            123456789, 'u-i-d')
    other = subject.from_hash(reference.to_hash)
    expect(reference.resource_id).to eq other.resource_id
    expect(reference.timestamp).to eq other.timestamp
    expect(reference.in).to eq other.in
    expect(reference.out).to eq other.out
  end

  it 'round-trip via json' do
    reference = subject.new(Time.new(123456789), 987654331,
                            123456789, 'u-i-d')
    other = subject.from_json(reference.to_hash.to_json)
    expect(reference.resource_id).to eq other.resource_id
    expect(reference.timestamp).to eq other.timestamp
    expect(reference.in).to eq other.in
    expect(reference.out).to eq other.out
  end
end

describe Buzzn::DataResultSet do

  subject { Buzzn::DataResultSet }

  [:milliwatt, :milliwatt_hour].each do |units|
    it "loads it hash representation for #{units}" do
      reference = subject.send(units, 'u-i-d')
      4.times.each do
        reference.add(Time.new(rand(12789)), rand(987654331),
                      [:in, :out].sample)
      end
      other = subject.from_hash(reference.to_hash)
      expect(reference.resource_id).to eq other.resource_id
      expect(reference.units).to eq other.units
      expect(reference.in).to eq other.in
      expect(reference.out).to eq other.out
    end

    it "round-trip via json for #{units}" do
      reference = subject.send(units, 'u-i-d')
      4.times.each do
        reference.add(Time.new(rand(16789)), rand(987654331),
                      [:in, :out].sample)
      end
      other = subject.from_hash(reference.to_hash)
      expect(reference.resource_id).to eq other.resource_id
      expect(reference.units).to eq other.units
      expect(reference.in).to eq other.in
      expect(reference.out).to eq other.out
    end

    it "adds for #{units}" do
      reference = subject.send(units, 'u-i-d')
      other = subject.send(units, 'u-i-d')
      4.times.each do
        reference.add(Time.new(rand(16789)), rand(987654331),
                      [:in, :out].sample)
      end
      other = subject.send(units, 'u-i-d')
      reference.in.each do |i|
        other.add(i.timestamp, 987654331 - i.value, :in)
      end
      reference.out.each do |i|
        other.add(i.timestamp, 987654331 - i.value, :out)
      end
      reference.add_all(other)
      expect(reference.in.size).to eq other.in.size
      expect(reference.out.size).to eq other.out.size
      (reference.in + reference.out).each do |r|
        expect(r.value).to eq 987654331
      end
    end
  end

  it "does not add" do
    reference = subject.milliwatt('u-i-d')
    other = subject.milliwatt_hour('u-i-d')
    expect { reference.add_all(other) }.to raise_error ArgumentError
  end
end


describe Buzzn::DataResultArray do

  subject { Buzzn::DataResultArray }
  
  it 'loads it hash representation' do
    reference = subject.new(987654331)
    4.times do
      reference << Buzzn::DataResult.new(Time.new(rand(123456789)),
                                         rand(987654331),
                                         'u-i-d',[:in, :out].sample,
                                         Time.current.to_f)
    end
    other = subject.from_hash(reference.to_hash)
    expect(reference.expires_at).to eq other.expires_at
    expect(reference).to eq other
  end

  it 'round-trip via json' do
    reference = subject.new(987654331)
    4.times do
      reference << Buzzn::DataResult.new(Time.new(rand(123456789)),
                                         rand(987654331),
                                         'u-i-d',[:in, :out].sample,
                                         Time.current.to_f)
    end
    other = subject.from_json(reference.to_json)
    expect(reference.expires_at).to eq other.expires_at
    expect(reference).to eq other
  end
end
  
