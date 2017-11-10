describe Buzzn::Services::DataSourceRegistry do

  subject { Buzzn::Services::DataSourceRegistry.new }

  module  Buzzn::Test
    class DataSource < Buzzn::DataSource
      NAME = 'test'
    end
  end

  it 'adds data-source' do
    expect { subject.get(Buzzn::Test::DataSource::NAME)}.to raise_error StandardError
    subject.add_source(Buzzn::Test::DataSource.new)
    expect(subject.get(Buzzn::Test::DataSource::NAME)).to be_a Buzzn::Test::DataSource
  end

  it 'finds added source in enumeration' do
    subject.add_source(Buzzn::Test::DataSource.new)

    found = nil
    subject.each do |data_source|
      found = data_source if data_source.is_a? Buzzn::Test::DataSource
    end
    expect(found).not_to be_nil
  end

  it 'can not add non Buzzn::DataSource classes' do
    expect { subject.add_source(:something) }.to raise_error ArgumentError
  end
end
