shared_examples 'create with nested person' do |method, params|

  entity(:person) { create(:person) }

  context 'without person' do
    it { expect(subject.(params.merge(method => {}))).to be_failure }
    it { expect(subject.(params)).to be_success }
    it { expect(subject.(params).output).to eq params }
  end

  context 'with person' do

    let(:nested_params) { params.merge(method => {first_name: 'Dagobert', prefix: 'M', last_name: 'Duck', preferred_language: 'en'}) }

    it { expect(subject.(params.merge(method => {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end

  context 'assign person' do

    let(:nested_params) { params.merge(method => {id: person.id}) }

    it { expect(subject.(params.merge(method => {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end
end

shared_examples 'update without nested person' do |method, params|

  let(:base_params) { params.merge(updated_at: DateTime.now) }

  context 'without person' do
    it { expect(subject.({})).to be_failure }
    it { expect(subject.(base_params)).to be_success }
    it { expect(subject.(base_params).output).to eq base_params }
  end

  context 'with person' do

    let(:nested_params) do
      base_params.merge(method => {prefix: 'M',
                                   first_name: 'Elvis',
                                   last_name: 'Presely',
                                   preferred_language: 'de'})
    end

    it { expect(subject.(base_params.merge(method => {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end

  context 'assign person' do

    let(:nested_params) { base_params.merge(method => {id: send(method).id}) }

    it { expect(subject.(params.merge(method => {}))).to be_failure }
    it { expect(subject.(nested_params)).to be_failure }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end
end

shared_examples 'update without nested person and address' do |method, params|

  let(:base_params) { params.merge(updated_at: DateTime.now) }

  let(:nested_params) do
    base_params.merge(method => {prefix: 'M',
                                 first_name: 'Elvis',
                                 last_name: 'Presely',
                                 preferred_language: 'de',
                                 address: {street: 'wallstreet',
                                           zip: '666',
                                           city: 'atlantis',
                                           country: 'IT'}})
  end

  it { expect(subject.(base_params.merge(method => {}))).to be_failure }
  it { expect(subject.(nested_params)).to be_success }
  it { expect(subject.(nested_params).output).to eq nested_params }

end

shared_examples 'update with nested person' do |method, params|

  let(:base_params) { params.merge(updated_at: DateTime.now) }

  context 'without person' do
    it { expect(subject.(base_params.merge(method => {}))).to be_failure }
    it { expect(subject.(base_params)).to be_success }
    it { expect(subject.(base_params).output).to eq base_params }
  end

  context 'with person' do

    let(:person_params) do
      {prefix: 'M',
       first_name: 'Elvis',
       last_name: 'Presely',
       preferred_language: 'de'}
    end

    let(:almost_nested_params) { base_params.merge(method => person_params) }

    let(:nested_params) do
      base_params.merge(method =>
                        person_params.merge(updated_at: DateTime.now))
    end

    it {
      expect(subject.(base_params.merge(method => {}))).to be_failure
    }
    it { expect(subject.(almost_nested_params)).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it {
      expect(subject.(nested_params).output).to eq nested_params
    }
  end

  context 'assign person' do

    let(:nested_params) { base_params.merge(method => {id: send(method).id}) }

    it {
      expect(subject.(params.merge(method => {}))).to be_failure
    }
    it { expect(subject.(nested_params)).to be_success }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end
end

shared_examples 'update with nested person and address' do |method, params|

  let(:person_params) do
    {prefix: 'M',
     first_name: 'Elvis',
     last_name: 'Presely',
     preferred_language: 'de'}
  end

  let(:address_params) do
    {street: 'wallstreet',
     zip: '666',
     city: 'atlantis',
     country: 'IT'}
  end

  let(:base_params) { params.merge(updated_at: DateTime.now) }

  let(:nested_params) do
    base_params.merge(method =>
                      person_params.merge(updated_at: DateTime.now,
                                          address: address_params))
  end

  entity!(:address) { send(method).address }

  context 'with address' do
    let(:almost_nested_params) do
      base_params.merge(method =>
                        person_params.merge(address: address_params))
    end
    let(:almost_nested_nested_params) do
      base_params.merge(method =>
                        person_params.merge(updated_at: DateTime.now,
                                            address: address_params))
    end
    let(:nested_params) do
      base_params.merge(method =>
                        person_params.merge(updated_at: DateTime.now,
                                            address: address_params.merge(updated_at: DateTime.now)))
    end
    before { send(method).update!(address: address) }
    it { expect(subject.(base_params.merge(method => {}))).to be_failure }
    it do
      expect(subject.(almost_nested_params)).to be_failure
    end
    it { expect(subject.(almost_nested_nested_params)).to be_failure }
    it {
      expect(subject.(nested_params)).to be_success
    }
    it { expect(subject.(nested_params).output).to eq nested_params }
  end

  context 'without address' do
    let(:almost_nested_params) do
      base_params.merge(method =>
                        person_params.merge(address: address_params))
    end
    let(:nested_params) do
      base_params.merge(method =>
                        person_params.merge(updated_at: DateTime.now,
                                            address: address_params))
    end
    before { send(method).update!(address: nil) }
    it { expect(subject.(base_params.merge(method => {}))).to be_failure }
    it { expect(subject.(almost_nested_params)).to be_failure }
    it { expect(subject.(nested_params)).to be_success }
    it do
      expect(subject.(nested_params).output).to eq nested_params
    end
  end
end
