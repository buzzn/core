require 'buzzn/schemas/invariants/register/base'
require 'buzzn/schemas/invariants/contract/base'

describe Operations::Action::Update do

  entity(:session) { Buzzn::Resource::SecurityContext.new }
  entity(:resource_with_invariant) { Contract::LocalpoolPowerTakerResource.new(create(:contract, :localpool_powertaker), session) }
  entity(:resource_without_invariant) { PersonResource.new(create(:person), session) }
  let(:input) { {} }

  context 'stale' do
    before { input[:updated_at] = Time.now - + 2.seconds }
    let(:resource) { [resource_with_invariant, resource_without_invariant].sample }
    it 'leaves with error' do
      expect{ subject.call(params: input, resource: resource) }.to raise_error Buzzn::StaleEntity
    end
  end

  context 'up to date' do
    let!(:updated_at) { resource_without_invariant.updated_at }
    before do
      input[:updated_at] = updated_at
    end

    context 'change' do
      before {input[:first_name] = 'Hektor'}
      it 'acts' do
        result = subject.call(params: input, resource: resource_without_invariant)

        expect(result).to be_a(PersonResource)
        expect(result).to be_persisted
        expect(result.updated_at).not_to eq updated_at
      end
    end

    context 'unchanged' do
      let!(:updated_at) { resource_without_invariant.updated_at }
      before {input.delete(:first_name)}
      it 'keeps as is' do
        result = subject.call(params: input, resource: resource_without_invariant)

        expect(result).to be_a(PersonResource)
        expect(result).to be_persisted
        expect(result.updated_at).to eq updated_at
      end
    end

    context 'broken invariant' do
      before do
        input.delete(:first_name)
        input[:end_date] = Date.today
        input[:updated_at] = resource_with_invariant.updated_at
      end
      it 'leaves with validation errors' do
        expect { subject.call(params: input, resource: resource_with_invariant) }.to raise_error Buzzn::ValidationError
        expect(resource_with_invariant.object).not_to be_changed
      end
    end
  end
end
