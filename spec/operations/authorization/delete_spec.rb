require 'ostruct'

describe Operations::Authorization::Delete do

  let(:resource) { OpenStruct.new(instance_class: Person, security_context: OpenStruct.new(current_user: nil)) }

  context 'allowed' do
    before { resource.send 'deletable?=', true }
    it 'passes given resource' do
      result = subject.call(resource: resource)
      expect(result).to be true
    end
  end

  context 'denied' do
    before { resource.send 'deletable?=', false }
    it 'leaves with error' do
      expect{ subject.call(resource: resource) }.to raise_error Buzzn::PermissionDenied
    end
  end
end
