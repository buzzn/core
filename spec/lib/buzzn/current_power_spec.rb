describe Buzzn::CurrentPower do

  class DummyDataSource < Buzzn::DataSource

    NAME = :dummy

    def single_aggregated(resource, mode)
      [:single_aggregated, resource, mode] unless resource.is_a? Group::Base
    end

    def collection(*args)
      [:collection] + args
    end
  end

  class MockDataSource < Buzzn::DataSource

    NAME = :mock

    attr_accessor :input, :output

    def single_aggregated(resource, mode)
      mode == :in ? @input : @output
    end

    def collection(*args)
      nil
    end
  end

  let(:mock) { MockDataSource.new }
  subject do
    Buzzn::CurrentPower.new(
      Buzzn::DataSourceRegistry.new(
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

  it 'delivers the right result for a register' do
    result = subject.for_register(dummy_register)
    expect(result).to eq [:single_aggregated, dummy_register, :in]

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
    mock.input = Buzzn::DataResult.new(Time.current,123, nil, :in)
    mock.output = Buzzn::DataResult.new(Time.current,321, nil, :out)
    result = subject.for_group(group)
    expect(result.resource_id).to eq group.id
    expect(result.in).to eq 123
    expect(result.out).to eq 321

    expect { subject.for_group(group, 'a') }.to raise_error ArgumentError
    expect { subject.for_group(Object.new) }.to raise_error ArgumentError
  end

  it 'delivers the right current power for a virtual register' do |spec|
    VCR.use_cassette("lib/buzzn/#{spec.metadata[:description].downcase}") do
      result = subject.for_register(virtual_register)
      result_single = subject.for_register(virtual_register.formula_parts.first.operand)
      expect(result).to eq result_single
    end
  end

end
