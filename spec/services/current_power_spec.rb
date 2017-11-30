describe Buzzn::Services::CurrentPower do

  class MockRegister < Register::Input
    def data_source; 'mock'; end
  end

  class DummyDataSource < Buzzn::DataSource

    NAME = :dummy

    def single_aggregated(resource, mode)
      if resource.is_a? Register::Base
        result = [:single_aggregated, resource, mode]
        def result.expires_at=(*a); end
        def result.value; 0; end
        result
      end
    end

    def collection(*args)
      result = [:collection] + args
      def result.expires_at;end
      result
    end
  end

  class MockDataSource < Buzzn::DataSource

    NAME = :mock

    attr_accessor :input, :output

    def single_aggregated(resource, mode)
      mode == 'in' ? @input.shift : @output.shift
    end

    def collection(*args)
      nil
    end
  end

  let(:mock) { MockDataSource.new }
  subject do
    Buzzn::Services::CurrentPower.new(
      Buzzn::Services::DataSourceRegistry.new(
        Redis.current,
        DummyDataSource.new,
        mock,
        Buzzn::CheckTypesDataSource.new
      )
    )
  end

  entity(:group) do
    create(:localpool)
    #Display::GroupResource.all(Fabricate(:admin)).first
  end

  entity(:register) { create(:register, :output) }

  entity(:dummy_register) do
    dummy = create(:register, :input)
    def dummy.data_source; 'dummy'; end
    def dummy.to_s; self.id; end
    dummy
  end

  entity(:mock_register) do
    mock = MockRegister.new(build(:register, :input).attributes.except('type'))
    mock.meter = FactoryGirl.build(:meter, :real, group: mock.group)
    mock.save!
    mock
  end

  entity(:virtual_register) do
    register = create(:register, :virtual_input, group: mock_register.group)
    create(:formula_part, :plus, register: register, operand: mock_register)
    create(:formula_part, :minus, register: register, operand: mock_register)
    create(:formula_part, :plus, register: register, operand: mock_register)
    register
  end

  it 'delivers the right result for a register' do
    result = subject.for_register(dummy_register)
    expect(result).to eq [:single_aggregated, dummy_register, 'in']

    expect { subject.for_register(register, 'a') }.to raise_error ArgumentError
    expect { subject.for_register(Object.new) }.to raise_error ArgumentError
  end

  it 'delivers the right result for each register in a group' do
    result = subject.for_each_register_in_group(group)
    expect(result).to eq [:collection, group, 'in', :collection, group, 'out']

    expect { subject.for_each_register_in_group(group, 'a') }.to raise_error ArgumentError
    expect { subject.for_each_register_in_group(Object.new) }.to raise_error ArgumentError
  end

  it 'delivers the right result for a group' do
    mock.input = [Buzzn::DataResult.new(Time.current,123, nil, 'in')]
    mock.output = [Buzzn::DataResult.new(Time.current,321, nil, 'out')]
    result = subject.for_group(group)
    expect(result.resource_id).to eq group.id
    expect(result.in).to eq 123
    expect(result.out).to eq 321

    expect { subject.for_group(group, 'a') }.to raise_error ArgumentError
    expect { subject.for_group(Object.new) }.to raise_error ArgumentError
  end

  it 'delivers the right current power for a virtual register' do |spec|
    # results for 'in' mode
    mock.input = [Buzzn::DataResult.new(Time.current,123, mock_register.id, 'in')] * 4

    result = subject.for_register(virtual_register)
    result_single = subject.for_register(virtual_register.formula_parts.first.operand)
    # the formula_parts are created to have the result of the first operand
    expect(result).to eq result_single
  end

end
