require_relative 'api_mock'

describe Services::Datasource::Discovergy::Throughput do

  let(:max) { Services::Datasource::Discovergy::Throughput::MAX_CONCURRENT_CONNECTIONS }

  let(:subject) { Import.global('services.datasource.discovergy.throughput') }

  it 'increments and decrements' do
    max.times do
      subject.increment!
    end
    expect(subject.current).to eq max
    max.times do
      subject.decrement
    end
    expect(subject.current).to eq 0
  end

  it 'fails when exceeding limit' do
    expect {
      (max + 1).times do
        subject.increment!
      end
    }.to raise_error Buzzn::DataSourceError
    expect(subject.current).to eq max
  end
end
