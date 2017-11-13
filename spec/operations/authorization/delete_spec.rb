require 'ostruct'

describe Operations::Authorization::Delete do

  let(:resource) { OpenStruct.new(instance_class: Person) }

  context 'allowed' do
    before { resource.send 'deletable?=', true }
    it 'passes given resource' do
      result = subject.call(resource)
      expect(result).to be_a Dry::Monads::Either::Right
      expect(result.value).to eq resource
    end
  end

  context 'denied' do
    before { resource.send 'deletable?=', false }
    it 'leaves with error' do
      expect{ subject.call(resource) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
