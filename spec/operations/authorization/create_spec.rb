require 'ostruct'

describe Operations::Authorization::Create do

  let(:resource) { OpenStruct.new(instance_class: Person, security_context: OpenStruct.new(current_user: nil)) }
  let(:input) { {a: 123} }

  context 'allowed' do
    before { resource.send 'createable?=', true }
    it 'passes input' do
      result = subject.call(params: input, resource: resource)
      expect(result).to be true
    end
  end

  context 'denied' do
    before { resource.send 'createable?=', false }
    it 'leaves with error' do
      expect{ subject.call(params: input, resource: resource) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
