require 'buzzn/schemas/invariants/group/localpool'
require_relative 'name_size_shared'

describe 'Schemas::Invariants::Group::Localpool' do

  entity(:localpool) { create(:group, :localpool) }

  context 'name' do
    it_behaves_like 'invariants of name-size', :localpool
  end

  context 'owner' do
    entity!(:person) { create(:person) }

    shared_examples 'an owner' do
      it 'valid' do
        person.add_role(Role::GROUP_OWNER, localpool)
        expect(localpool.invariant.errors[:owner]).to be_nil
      end

      it 'invalid' do
        person.remove_role(Role::GROUP_OWNER, localpool)
        expect(localpool.invariant.errors[:owner]).not_to be_nil
      end
    end

    context 'person' do
      before { localpool.update(owner: person) }
      it_behaves_like 'an owner'
    end

    context 'organization' do
      entity!(:organization) { create(:organization, contact: person) }

      before { localpool.update(owner: organization) }
      it_behaves_like 'an owner'
    end
  end

  context 'distribution_system_operator' do

    before(:each) do localpool.update(transmission_system_operator: nil,
                                      electricity_supplier: nil) end

    it 'invalid' do
      localpool.update(distribution_system_operator: Organization::Market.transmission_system_operators.first)
      expect(localpool.invariant.errors[:distribution_system_operator]).not_to be_nil
      expect(localpool.distribution_system_operator).not_to be_nil
    end

    it 'valid' do
      localpool.update(distribution_system_operator: Organization::Market.distribution_system_operators.first)
      expect(localpool.invariant.errors[:distribution_system_operator]).to be_nil
      expect(localpool.distribution_system_operator).not_to be_nil
    end
  end

  context 'transmission_system_operator' do
    before(:each) do localpool.update(distribution_system_operator: nil,
                                      electricity_supplier: nil) end

    it 'invalid' do
      localpool.update(transmission_system_operator: Organization::Market.distribution_system_operators.first)
      expect(localpool.invariant.errors[:transmission_system_operator]).not_to be_nil
      expect(localpool.transmission_system_operator).not_to be_nil
    end

    it 'valid' do
      localpool.update(transmission_system_operator: Organization::Market.transmission_system_operators.first)
      expect(localpool.invariant.errors[:transmission_system_operator]).to be_nil
      expect(localpool.transmission_system_operator).not_to be_nil
    end
  end

  context 'electricity_supplier' do
    before(:each) do localpool.update(transmission_system_operator: nil,
                                      distribution_system_operator: nil) end

    it 'invalid' do
      localpool.update(electricity_supplier: Organization::Market.transmission_system_operators.first)
      expect(localpool.invariant.errors[:electricity_supplier]).not_to be_nil
      expect(localpool.electricity_supplier).not_to be_nil
    end

    it 'valid' do
      localpool.update(electricity_supplier: Organization::Market.electricity_suppliers.first)
      expect(localpool.invariant.errors[:electricity_supplier]).to be_nil
      expect(localpool.electricity_supplier).not_to be_nil
    end
  end

  shared_examples 'invariants of a grid connected register' do |label|

    before { localpool.meters.clear }

    # will return the grid_feeding or grid_consumption register
    let(:tested_register)   { localpool.send("#{label}_register") }
    let(:tested_invariants) { localpool.invariant.errors[:"#{label}_register"] }

    subject { tested_invariants }

    def make_register(localpool, label:)
      meter = create(:meter, :real, group: localpool, register_label: label)
      meter.registers.first
    end

    context 'when there is no such register' do
      before do
        expect(tested_register).to be_nil # assert precondition
      end
      it { is_expected.to be_nil }
    end

    context 'when there is one such register' do
      before do
        make_register(localpool, label: label)
        expect(tested_register).not_to be_nil # assert precondition
      end
      it { is_expected.to be_nil }
    end

    context 'when there are two such registers' do
      before do
        2.times { make_register(localpool, label: label) }
        expect(tested_register).not_to be_nil # assert precondition
      end
      it { is_expected.to eq(['must not have more than register with this label']) }
    end
  end

  describe 'grid feeding register' do
    it_behaves_like 'invariants of a grid connected register', :grid_feeding
  end

  describe 'grid consumption register' do
    it_behaves_like 'invariants of a grid connected register', :grid_consumption
  end

end
