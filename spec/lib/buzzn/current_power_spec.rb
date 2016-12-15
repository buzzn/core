describe Buzzn::CurrentPower do

  class DummyDataSource

    def method_missing(method, *args)
      [method] + args
    end

    def single_aggregated(resource, mode)
      method_missing(:single_aggregated, resource, mode) unless resource.is_a? Group
    end
  end

  class MockDataSource

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
    Buzzn::CurrentPower.new(Buzzn::DataSourceRegistry.new(dummy: DummyDataSource.new, mock: mock))
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
    result = subject.for_register(dummy_register)
    expect(result).to eq [:single_aggregated, dummy_register, :in]

    expect { subject.for_register(register) }.to raise_error ArgumentError
  end

  it 'delivers the right result for each register in a group' do
    result = subject.for_each_register_in_group(group)
    expect(result).to eq [:collection, group, :in, :collection, group, :out]
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
  end

end
