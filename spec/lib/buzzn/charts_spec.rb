describe Buzzn::CurrentPower do

  class DummyDataSource

    def method_missing(method, *args)
      [method] + args
    end

    def aggregated(resource, mode, interval)
      method_missing(:aggregated, resource, mode, interval) unless resource.is_a? Group
    end
  end

  class MockDataSource

    attr_accessor :input, :output

    def aggregated(resource, mode, interval)
      mode == :in ? @input : @output
    end

    def method_missing(method, *args)
      nil
    end
  end

  let(:mock) { MockDataSource.new }
  subject do
    Buzzn::Charts.new(Buzzn::DataSourceRegistry.new(dummy: DummyDataSource.new, mock: mock))
  end

  let(:group) { Fabricate(:group) }
  let(:register) { Fabricate(:output_register) }
  let(:dummy_register) do
    register = Fabricate(:input_register)
    def register.data_source; 'dummy';end
    def register.to_s; self.id; end
    register
  end

  it 'delivers the right result for a register' do
    interval = Buzzn::Interval.year
    result = subject.for_register(dummy_register, interval)
    expect(result).to eq [:aggregated, dummy_register, :in, interval]

    expect { subject.for_register(register) }.to raise_error ArgumentError
  end

  it 'delivers the right result for each register in a group' do
    mock.input = Buzzn::DataResultSet.milliwatt_hour(group.id, [Buzzn::DataPoint.new(Time.current, 123)], [])
    mock.output = Buzzn::DataResultSet.milliwatt_hour(group.id, [], [Buzzn::DataPoint.new(Time.current, 321)])
    interval = Buzzn::Interval.year
    result = subject.for_group(group, interval)
    expect(result.resource_id).to eq group.id
    expect(result.units).to eq :milliwatt_hour
    expect(result.in.first.value).to eq 123
    expect(result.out.first.value).to eq 321

    expect { subject.for_group(group, Buzzn::Interval.hour) }.to raise_error ArgumentError
  end
end
