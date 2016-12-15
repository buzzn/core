describe Buzzn::CurrentPower do

  class DummyDataSource < Buzzn::DataSource

    def single_aggregated(resource, mode)
      [:single_aggregated, resource, mode] unless resource.is_a? Group
    end

    def collection(*args)
      [:collection] + args
    end
  end

  class MockDataSource < Buzzn::DataSource

    attr_accessor :input, :output

    def single_aggregated(resource, mode)
      mode == :in ? @input : @output
    end

    def method_missing(method, *args)
      nil
    end
  end

  let(:mock) { MockDataSource.new }
  subject do
    Buzzn::CurrentPower.new(Buzzn::DataSourceRegistry.new(Redis.current, dummy: DummyDataSource.new, mock: mock, check: Buzzn::CheckTypesDataSource.new))
  end

  let(:group) { Fabricate(:group) }
  let(:register) { Fabricate(:output_register) }
  let(:dummy_register) do
    register = Fabricate(:input_register)
    def register.data_source; 'dummy';end
    def register.to_s; self.id; end
    register
  end
  let(:group_with_register) do
    register = Fabricate(:output_register, group: group)
    def register.data_source; 'mock';end
    group
  end

  it 'delivers the right result for a register' do
    result = subject.for_register(dummy_register)
    expect(result).to eq [:single_aggregated, dummy_register, :in]

    expect { subject.for_register(register) }.to raise_error ArgumentError
    expect { subject.for_register(register, 'a') }.to raise_error ArgumentError
    expect { subject.for_register(Object.new) }.to raise_error ArgumentError
  end

  it 'delivers the right result for each register in a group' do
    result = subject.for_each_register_in_group(group)
    expect(result).to eq [:collection, group, :in, :collection, group, :out]

    expect { subject.for_each_register_in_group(group, 'a') }.to raise_error ArgumentError
    expect { subject.for_each_register_in_group(Object.new) }.to raise_error ArgumentError
  end

  it 'delivers the right result for a group' do
    mock.input = Buzzn::DataResult.new(Time.current,
                                       123, nil, :in)
    mock.output = Buzzn::DataResult.new(Time.current,
                                        321, nil, :out)
    result = subject.for_group(group)
    expect(result.resource_id).to eq group.id
    expect(result.in).to eq 123
    expect(result.out).to eq 321

    expect { subject.for_group(group, 'a') }.to raise_error ArgumentError
    expect { subject.for_group(Object.new) }.to raise_error ArgumentError
  end

end
