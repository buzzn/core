shared_examples 'create with nested address' do |params|

  context 'without address' do
    it { expect(subject.({})).to be_failure }
    it { expect(subject.(params)).to be_success }
    it { expect(subject.(params).output).to eq params }
  end

  context 'with address' do

    let(:nested_params) { params.merge(address: {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'}) }

    it { expect(subject.(params.merge(address: {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end
end

shared_examples 'update with nested address' do |params|

  let(:base_params) { params.merge(updated_at: Date.today.as_json) }

  context 'without address' do
    it { expect(subject.(base_params.merge(address: {}))).to be_failure }
    it { expect(subject.(base_params)).to be_success }
    it { expect(subject.(base_params).output).to eq base_params }
  end

  context 'with address' do

    let(:almost_nested_params) do
      base_params.merge(address: {street: 'wallstreet',
                                  zip: '666',
                                  city: 'atlantis',
                                  country: 'IT'})
    end

    let(:nested_params) do
      base_params.merge(address: {street: 'wallstreet',
                                  zip: '666',
                                  city: 'atlantis',
                                  country: 'IT',
                                  updated_at: Date.today.as_json})
    end

    it { expect(subject.(base_params.merge(address: {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end
end

shared_examples 'update without nested address' do |params|

  let(:base_params) { params.merge(updated_at: Date.today.as_json) }

  context 'without address' do
    it { expect(subject.(base_params.merge(address: {}))).to be_failure }
    it { expect(subject.(base_params)).to be_success }
    it { expect(subject.(base_params).output).to eq base_params }
  end

  context 'with address' do

    let(:nested_params) do
      base_params.merge(address: {street: 'wallstreet',
                                  zip: '666',
                                  city: 'atlantis',
                                  country: 'IT'})
    end

    it { expect(subject.(base_params.merge(address: {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end
end
