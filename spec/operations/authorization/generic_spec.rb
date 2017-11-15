require 'ostruct'

describe Operations::Authorization::Generic do

  let(:resource) do
    r = OpenStruct.new(instance_class: Person)
    def r.allowed?(*args);allowed; end
    r
  end
  let(:input) { {a: 123} }

  context 'allowed' do
    before { resource.allowed = true }
    it 'passes input' do
      result = subject.call(input, resource)
      expect(result).to be_a Dry::Monads::Either::Right
      expect(result.value).to eq input
    end
  end

  context 'denied' do
    before { resource.allowed = false }
    it 'leaves with error' do
      expect{ subject.call(input, resource) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
