describe Buzzn::Services::Charts do


  class DummyDataSource < Buzzn::DataSource
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
    Buzzn::Services::Charts.new(
      Buzzn::Services::DataSourceRegistry.new(
        Redis.current,
        DummyDataSource.new,
        mock,
        Buzzn::CheckTypesDataSource.new
      )
    )
  end

  let(:group) { Fabricate(:tribe) }
  let(:register) { Fabricate(:output_meter).output_register }
  let(:dummy_register) do
    register = Fabricate(:input_meter).input_register
    def register.data_source; 'dummy';end
    def register.to_s; self.id; end
    register
  end

  let(:virtual_register) do
    easymeter_60051599 = Fabricate(:easymeter_60051599)
    easymeter_60051599.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051599", resource: easymeter_60051599)
    fichtenweg8 = Fabricate(:virtual_meter_fichtenweg8).register
    Fabricate(:fp_plus, operand: easymeter_60051599.registers.first, register: fichtenweg8)
    Fabricate(:fp_plus, operand: easymeter_60051599.registers.first, register: fichtenweg8)
    Fabricate(:fp_minus, operand: easymeter_60051599.registers.first, register: fichtenweg8)
    fichtenweg8
  end


  it 'delivers the right result for a real register', retry: 3 do
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


  it 'delivers the right result for a virtual register', retry: 3 do |spec|
    VCR.use_cassette("lib/buzzn/#{spec.metadata[:description].downcase}") do
      interval = Buzzn::Interval.day
      result = subject.for_register(virtual_register, interval)
      result_single = subject.for_register(virtual_register.formula_parts.first.operand, interval)
      expect(result.in).to eq result_single.out
    end
  end


end
