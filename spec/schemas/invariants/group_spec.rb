require 'buzzn/schemas/invariants/group/localpool'

describe 'Schemas::Invariants::Group::Localpool' do

  entity(:localpool) { create(:localpool) }

  it 'valid on bare localpool' do
    expect(localpool).to have_valid_invariants
  end

  context 'distribution_system_operator' do

    before(:each) { localpool.update(transmission_system_operator: nil,
                                     electricity_supplier: nil) }

    it 'invalid' do
      localpool.update(distribution_system_operator: Organization.transmission_system_operator.first)
      expect(localpool.invariant.errors[:distribution_system_operator]).not_to be_nil
    end

    it 'valid' do
      localpool.update(distribution_system_operator: Organization.distribution_system_operator.first)
      expect(localpool).to have_valid_invariants
      expect(localpool.distribution_system_operator).not_to be_nil
    end
  end

  context 'transmission_system_operator' do
    before(:each) { localpool.update(distribution_system_operator: nil,
                                     electricity_supplier: nil) }

    it 'invalid' do
      localpool.update(transmission_system_operator: Organization.distribution_system_operator.first)
      expect(localpool.invariant.errors[:transmission_system_operator]).not_to be_nil
    end

    it 'valid' do
      localpool.update(transmission_system_operator: Organization.transmission_system_operator.first)
      expect(localpool).to have_valid_invariants
      expect(localpool.transmission_system_operator).not_to be_nil
    end
  end

  context 'electricity_supplier' do
    before(:each) { localpool.update(transmission_system_operator: nil,
                                     distribution_system_operator: nil) }

    it 'invalid' do
      localpool.update(electricity_supplier: Organization.distribution_system_operator.first)
      expect(localpool.invariant.errors[:electricity_supplier]).not_to be_nil
    end

    it 'valid' do
      localpool.update(electricity_supplier: Organization.electricity_supplier.first)
      expect(localpool).to have_valid_invariants
      expect(localpool.electricity_supplier).not_to be_nil
    end
  end
end

  # context 'invariants' do

  #   it 'valid' do
  #     resources.each do |contract|
  #       contract.object.update begin_date: nil, termination_date: nil, end_date: nil
  #       expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base

  #       contract.object.update begin_date: Date.today
  #       expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base

  #       contract.object.update termination_date: Date.today
  #       expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base

  #       contract.object.update end_date: Date.today
  #       expect(contract).to have_valid_invariants Schemas::Invariants::Contract::Base
  #     end
  #   end

  #   context 'invalid' do
  #     it 'missing begin_date and termination_date' do
  #       resources.each do |contract|
  #         contract.object.update begin_date: nil, termination_date: nil, end_date: Date.today
  #         expect(contract).not_to have_valid_invariants Schemas::Invariants::Contract::Base
  #         expect(Schemas::Invariants::Contract::Base.call(contract).messages).to eq({:begin_date=>["must be filled"], :termination_date=>["must be filled"]})
  #       end
  #     end

  #     it 'missing begin_date' do
  #       resources.each do |contract|
  #         contract.object.update begin_date: nil, termination_date: Date.today, end_date: Date.today
  #         expect(contract).not_to have_valid_invariants Schemas::Invariants::Contract::Base
  #         expect(Schemas::Invariants::Contract::Base.call(contract).messages).to eq({:begin_date=>["must be filled"]})
  #       end
  #     end

  #     it 'missing termination date' do
  #       resources.each do |contract|
  #         contract.object.update begin_date: Date.today, termination_date: nil, end_date: Date.today
  #         expect(contract).not_to have_valid_invariants Schemas::Invariants::Contract::Base
  #         expect(Schemas::Invariants::Contract::Base.call(contract).messages).to eq({:termination_date=>["must be filled"]})
  #       end
  #     end
  #   end
  # end
#end
