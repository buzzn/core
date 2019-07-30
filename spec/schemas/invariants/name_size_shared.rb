shared_examples 'invariants of name-size' do |reference_name|

  let(:object) { send(reference_name) }
  let(:tested_invariants) { object.invariant.errors[:name] }

  subject { tested_invariants }

  context 'when there is empty name' do
    before do
      object.name = ''
    end
    it { is_expected.to eq(['must be filled']) }
  end

  context 'when there is short name' do
    before do
      object.name = 'I'
    end
    it { is_expected.to eq(['size cannot be less than 4']) }
  end

  context 'when there is a proper name' do
    before do
      object.name = 'Hase und Igel'
    end
    it { is_expected.to be_nil }
  end

  context 'when there is long name' do
    before do
      object.name = 'Hase und Igel' * 100
    end
    it { is_expected.to eq(['size cannot be greater than 64']) }
  end

  after { object.name = 'Hase und Igel' }
end
