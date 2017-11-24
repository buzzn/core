require 'buzzn/schemas/invariants/group/localpool'

describe 'Schemas::Invariants::Group::Localpool' do

  entity(:localpool) { create(:localpool) }

  it 'valid on bare localpool' do
    expect(localpool).to have_valid_invariants
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
      it_behaves_like "an owner"
    end
    context 'organization' do
      entity!(:organization) { create(:organization, contact: person) }

      before { localpool.update(owner: organization) }
      it_behaves_like "an owner"
    end
  end

  context 'distribution_system_operator' do

    before(:each) { localpool.update(transmission_system_operator: nil,
                                     electricity_supplier: nil) }

    it 'invalid' do
      localpool.update(distribution_system_operator: Organization.transmission_system_operator.first)
      expect(localpool.invariant.errors[:distribution_system_operator]).not_to be_nil
      expect(localpool.distribution_system_operator).not_to be_nil
    end

    it 'valid' do
      localpool.update(distribution_system_operator: Organization.distribution_system_operator.first)
      expect(localpool.invariant.errors[:distribution_system_operator]).to be_nil
      expect(localpool.distribution_system_operator).not_to be_nil
    end
  end

  context 'transmission_system_operator' do
    before(:each) { localpool.update(distribution_system_operator: nil,
                                     electricity_supplier: nil) }

    it 'invalid' do
      localpool.update(transmission_system_operator: Organization.distribution_system_operator.first)
      expect(localpool.invariant.errors[:transmission_system_operator]).not_to be_nil
      expect(localpool.transmission_system_operator).not_to be_nil
    end

    it 'valid' do
      localpool.update(transmission_system_operator: Organization.transmission_system_operator.first)
      expect(localpool.invariant.errors[:transmission_system_operator]).to be_nil
      expect(localpool.transmission_system_operator).not_to be_nil
    end
  end

  context 'electricity_supplier' do
    before(:each) { localpool.update(transmission_system_operator: nil,
                                     distribution_system_operator: nil) }

    it 'invalid' do
      localpool.update(electricity_supplier: Organization.transmission_system_operator.first)
      binding.pry unless localpool.invariant.errors[:electricity_supplier]
      expect(localpool.invariant.errors[:electricity_supplier]).not_to be_nil
      expect(localpool.electricity_supplier).not_to be_nil
    end

    it 'valid' do
      localpool.update(electricity_supplier: Organization.electricity_supplier.first)
      expect(localpool.invariant.errors[:electricity_supplier]).to be_nil
      expect(localpool.electricity_supplier).not_to be_nil
    end
  end

  context 'grid_consumption_register' do
    entity(:register) { Fabricate(:input_meter).input_register }
    before { localpool.update(grid_consumption_register: register) }
    context 'no meter.group' do
      before { register.meter.group = nil }
      context 'meter.register.group' do
        before { register.group = localpool }
        it 'is broken' do
          expect(localpool.invariant.errors[:grid_consumption_register]).not_to be_nil
        end
      end
      context 'no meter.register.group' do
        before { register.group = nil }
        it 'is broken' do
          expect(localpool.invariant.errors[:grid_consumption_register]).not_to be_nil
        end
      end
    end

    context 'right meter.group' do
      before { register.meter.group = localpool }
      context 'no meter.register.group' do
        before { register.group = nil }
        it 'is valid' do
          expect(localpool.invariant.errors[:grid_consumption_register]).to be_nil
        end
      end
      context 'meter.register.group' do
        before { register.group = localpool }
        it 'is broken' do
          expect(localpool.invariant.errors[:grid_consumption_register]).not_to be_nil
        end
      end
    end

    context 'wrong meter.group' do
      entity(:other) { Fabricate(:localpool, owner: nil) }
      before { register.meter.group = other }
      context 'no meter.register.group' do
        before { register.group = nil }
        it 'is broken' do
          expect(localpool.invariant.errors[:grid_consumption_register]).not_to be_nil
        end
      end
      context 'meter.register.group' do
        before { register.group = localpool }
        it 'is broken' do
          expect(localpool.invariant.errors[:grid_consumption_register]).not_to be_nil
        end
      end
    end
  end
end
