require 'dry/container/stub'

describe Operations::Discovergy do

  class Meters

    attr_accessor :connected
    def connected?(meter)
      @connected
    end

  end

  class Resource

    attr_accessor :object

  end

  entity(:meters) { Meters.new }

  before do
    Import.container.enable_stubs!
    Import.container.stub('services.datasource.discovergy.meters', meters)
  end

  after do
    Import.container.unstub('services.datasource.discovergy.meters')
  end

  entity(:meter) { create(:meter, :real, group: nil) }
  entity(:resource) do
    r = Resource.new
    r.object = meter
    r
  end

  context 'no discovergy meter' do
    before { meter.standard_profile! }
    it do
      expect(subject.call(resource: resource)).to be true
    end
  end

  context 'discovergy meter' do
    before { meter.discovergy! }
    it 'connected' do
      meters.connected = true
      expect(subject.call(resource: resource)).to be true
    end
    it 'not connected' do
      meters.connected = false
      expect { subject.call(resource: resource) }.to raise_error Buzzn::ValidationError
    end
  end

end
