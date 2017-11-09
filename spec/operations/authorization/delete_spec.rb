require 'ostruct'

describe Operations::Authorization::Delete do

  let(:resource) { OpenStruct.new(instance_class: Person) }
  let(:input) { {a: 123} }

  context 'allowed' do
    before { resource.send 'deletable?=', true }
    it 'passes input' do
      result = subject.call(input, resource)
      expect(result).to be_a Dry::Monads::Either::Right
      expect(result.value).to eq input
    end
  end

  context 'denied' do
    before { resource.send 'deletable?=', false }
    it 'leaves with error' do
      expect{ subject.call(input, resource) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
