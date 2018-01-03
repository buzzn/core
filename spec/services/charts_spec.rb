require 'buzzn/check_types_data_source'

describe Services::Charts do

  class MockRegister < Register::Input
    def data_source; 'mock'; end
  end

  class ChartsDummyDataSource < Buzzn::DataSource
    NAME = :dummy
    def method_missing(method, *args)
      # this is just an array with an extra expires_at field
      result = [method] + args
      def result.expires_at=(a);end
      result
    end
    def aggregated(resource, mode, interval)
      method_missing(:aggregated, resource, mode, interval) unless resource.is_a? Group::Base
    end
  end

  class ChartsMockDataSource < Buzzn::DataSource
    NAME = :mock
    attr_accessor :input, :output
    def aggregated(resource, mode, interval)
      mode == 'in' ? @input.shift : @output.shift
    end
    def method_missing(method, *args)
      nil
    end
  end

  let(:mock) { ChartsMockDataSource.new }
  subject do
    Services::Charts.new(
      Services::DataSourceRegistry.new(
        Redis.current,
        ChartsDummyDataSource.new,
        mock,
        Buzzn::CheckTypesDataSource.new
      )
    )
  end

  entity(:group) { create(:localpool) }
  entity(:register) { create(:register, :output) }
  entity(:dummy_register) do
    dummy = create(:register, :input)
    def dummy.data_source; 'dummy'; end
    def dummy.to_s; self.id; end
    dummy
  end

  entity(:mock_register) do
    mock = MockRegister.new(build(:register, :input).attributes.except('type'))
    mock.meter = FactoryGirl.build(:meter, :real, group: group)
    mock.save!
    mock
  end

  entity(:virtual_register) do
    register = create(:meter, :virtual, group: mock_register.meter.group).register
    create(:formula_part, :plus, register: register, operand: mock_register)
    create(:formula_part, :minus, register: register, operand: mock_register)
    register
  end

  it 'delivers the right result for a real register' do
    interval = Buzzn::Interval.year
    result = subject.for_register(dummy_register, interval)
    expect(result).to eq [:aggregated, dummy_register, 'in', interval]

    expect { subject.for_register(register) }.to raise_error ArgumentError
    expect { subject.for_register(Object.new, interval) }.to raise_error ArgumentError
  end

  it 'delivers the right result for each register in a group' do
    # setup the results for the MockDataSource which we use here
    # it just ignores the group and its missing registers and delivers
    # results for either mode
    mock.input = [Buzzn::DataResultSet.milliwatt_hour(group.id, [Buzzn::DataPoint.new(Time.current, 123)], [])]
    mock.output = [Buzzn::DataResultSet.milliwatt_hour(group.id, [], [Buzzn::DataPoint.new(Time.current, 321)])]
    interval = Buzzn::Interval.year
    result = subject.for_group(group, interval)
    expect(result.resource_id).to eq group.id
    expect(result.units).to eq :milliwatt_hour
    expect(result.in.first.value).to eq 123
    expect(result.out.first.value).to eq 321

    expect { subject.for_group(group) }.to raise_error ArgumentError
    expect { subject.for_group(Object.new, interval) }.to raise_error ArgumentError
  end

  it 'delivers the right result for a virtual register' do |spec|
    # results for 'in' mode
    mock.input = [Buzzn::DataResultSet.milliwatt_hour(group.id, [Buzzn::DataPoint.new(Time.current, 123)], [])] * 3
    interval = Buzzn::Interval.year
    result = subject.for_register(virtual_register, interval)
    result_single = subject.for_register(virtual_register.formula_parts.first.operand, interval)
    expect(result.in).to eq result_single.in
  end
end
