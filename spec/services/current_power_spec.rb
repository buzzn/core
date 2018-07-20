describe Services::CurrentPower do

  class MockRegister < Register::Real

    def datasource; 'mock'; end

  end

  class MockDataSource

    include Import['services.datasource.registry']

    NAME = :mock

    attr_accessor :result

    def initialize(**)
      super
      registry.add_source(self)
    end

    def ticker(register)
      result
    end

    def bubbles(group)
      nil
    end

    def daily_charts(group)
      nil
    end

  end

  entity!(:mock) { MockDataSource.new }
  before { mock }

  entity(:register) do
    mock = MockRegister.new(build(:register, :input).attributes.except('type'))
    mock.meter = FactoryGirl.build(:meter, :real)
    mock.save!
    mock
  end

  it 'tickers' do
    mock.result = '{}'
    result = subject.ticker(register)
    expect(result.time_to_live).to eq 15
    expect(result.json).to eq mock.result.to_json
  end
end
