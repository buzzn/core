describe Buzzn::Charts do

  class DummyDataSource < Buzzn::DataSource

    NAME = :dummy

    def method_missing(method, *args)
      [method] + args
    end

    def aggregated(resource, mode, interval)
      method_missing(:aggregated, resource, mode, interval) unless resource.is_a? Group
    end
  end

  class MockDataSource < Buzzn::DataSource

    NAME = :mock

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
    Buzzn::Charts.new(Buzzn::DataSourceRegistry.new(Redis.current, DummyDataSource.new, mock, Buzzn::CheckTypesDataSource.new))
  end

  let(:group) { Fabricate(:group) }
  let(:register) { Fabricate(:output_meter).output_register }
  let(:dummy_register) do
    register = Fabricate(:input_meter).input_register
    def register.data_source; 'dummy';end
    def register.to_s; self.id; end
    register
  end

  it 'delivers the right result for a register' do
    interval = Buzzn::Interval.year
    result = subject.for_register(dummy_register, interval)
    expect(result).to eq [:aggregated, dummy_register, :in, interval]

    expect { subject.for_register(register) }.to raise_error ArgumentError
    expect { subject.for_register(Object.new, interval) }.to raise_error ArgumentError
  end

  it 'delivers the right result for each register in a group' do
    # setup the results for the MockDataSource which we use here
    # it just ignores the group and its missing registers and delivers
    # results for either mode
    mock.input = Buzzn::DataResultSet.milliwatt_hour(group.id, [Buzzn::DataPoint.new(Time.current, 123)], [])
    mock.output = Buzzn::DataResultSet.milliwatt_hour(group.id, [], [Buzzn::DataPoint.new(Time.current, 321)])
    interval = Buzzn::Interval.year
    result = subject.for_group(group, interval)
    expect(result.resource_id).to eq group.id
    expect(result.units).to eq :milliwatt_hour
    expect(result.in.first.value).to eq 123
    expect(result.out.first.value).to eq 321

    expect { subject.for_group(group, Buzzn::Interval.hour) }.to raise_error ArgumentError
    expect { subject.for_group(group) }.to raise_error ArgumentError
    expect { subject.for_group(Object.new, interval) }.to raise_error ArgumentError
  end
end
