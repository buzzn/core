shared_examples 'create without person' do |transaction, expected_class, method, params|

  let(:result) do
    transaction.(params: params, resource: resource).value!
  end

  it { expect(result.send(method)).to be nil }
  it { expect(result).to be_a expected_class }

end

shared_examples 'create with person without address' do |transaction, expected_class, method, params|

  let(:person) { {prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de'} }

  let(:eextra_args) { (defined? extra_args).nil? ? {} : extra_args }

  let(:result) do
    transaction.({params: params.merge(method => person),
                  resource: resource}.merge(eextra_args)).value!
  end

  it { expect(result.send(method)).to be_a PersonResource }
  it { expect(result.send(method).object.address).to be nil }
  it { expect(result).to be_a expected_class }

end

shared_examples 'create with person with address' do |transaction, expected_class, method, params|

  let(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'} }

  let(:person) { {prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de', address: address} }

  let(:eextra_args) { (defined? extra_args).nil? ? {} : extra_args }

  let(:result) do
    transaction.({params: params.merge(method => person),
                  resource: resource}.merge(eextra_args)).value!
  end

  it { expect(result.send(method)).to be_a PersonResource }
  it { expect(result).to be_a expected_class }
  it { expect(result.send(method).address).to be_a AddressResource }

end

shared_examples 'update without person' do |transaction, method, params|

  let(:object) do
    o = resource.object
    o.update!(method => nil)
    o.reload
  end

  let(:eextra_args) { (defined? extra_args).nil? ? {} : extra_args }

  let(:result) do
    transaction.({params: params.merge(updated_at: object.updated_at.as_json),
                  resource: resource}.merge(eextra_args)).value!
  end

  it { expect(result).to be_a resource.class }
  params.each do |k, v|
    it { expect(result.send(k)).to eq(v) }
  end
  it { expect(result.send(method)).to be nil }

  context 'create person' do

    let(:result2) do
      transaction.({params: {
        updated_at: object.reload.updated_at.as_json,
        method => {
          prefix: 'M',
          first_name: 'Elvis',
          last_name: 'Presely',
          preferred_language: 'de'
        }
      },
                    resource: resource}.merge(eextra_args))
    end

    it { expect(result2.value!).to be_a resource.class }
    it { expect(result2).to be_success }
    it { expect(result2.value!.send(method)).to be_a PersonResource }
    it { expect(result2.value!.send(method).first_name).to eq 'Elvis' }
  end
end

shared_examples 'update with person without address' do |transaction, method, params|

  let(:eextra_args) { (defined? extra_args).nil? ? {} : extra_args }

  let(:object) do
    o = resource.object
    o.update!(method => create(:person))
    o.reload
  end

  let!(:result) do
    transaction.({params: params.merge(updated_at: object.updated_at.as_json),
                  resource: resource}.merge(eextra_args)).value!
  end

  it { expect(result).to be_a resource.class }
  params.each do |k, v|
    it { expect(result.send(k)).to eq(v) }
  end
  it { expect(result.send(method)).to be_a PersonResource }

  context 'update person' do

    let(:result2) do
      transaction.({params: {
        updated_at: object.reload.updated_at.as_json,
        method => {
          first_name: 'Jimi',
          last_name: 'Hendrix',
          updated_at: object.send(method).updated_at.as_json
        }
      },
                    resource: resource}.merge(eextra_args)).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.send(method)).to be_a PersonResource }
    it { expect(result2.send(method).first_name).to eq 'Jimi' }
    it { expect(result2.send(method).last_name).to eq 'Hendrix' }

  end

end

shared_examples 'update with person with address' do |transaction, method, params|

  let(:eextra_args) { (defined? extra_args).nil? ? {} : extra_args }

  let(:object) do
    o = resource.object
    o.update!(method => create(:person))
    o.reload
  end

  let!(:address) { object.address }

  let!(:result) do
    transaction.({params: params.merge(updated_at: object.updated_at.as_json),
                  resource: resource}.merge(eextra_args)).value!
  end

  it { expect(result).to be_a resource.class }
  params.each do |k, v|
    it { expect(result.send(k)).to eq(v) }
  end
  it { expect(result.send(method)).to be_a PersonResource }

  context 'update person and update address' do

    let!(:address2) do
      address = create(:address)
      object.send(method).update!(address: address)
      address
    end

    let(:result2) do
      transaction.({params: {
        updated_at: object.reload.updated_at.as_json,
        method => {
          first_name: 'Jimi',
          last_name: 'Hendrix',
          updated_at: object.send(method).reload.updated_at.as_json,
          address: {
            street: 'paint it black',
            updated_at: address2.reload.updated_at.as_json
          }
        }
      },
                    resource: resource}.merge(eextra_args)).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.send(method)).to be_a PersonResource }
    it { expect(result2.send(method).first_name).to eq 'Jimi' }
    it { expect(result2.send(method).last_name).to eq 'Hendrix' }
    it { expect(result2.send(method).address).to be_a AddressResource }
    it { expect(result2.send(method).address.street).to eq 'paint it black' }

  end

  context 'update person and create address' do

    let!(:address3) { object.send(method).update!(address: nil) }

    let(:result3) do
      transaction.({params: {
        updated_at: object.reload.updated_at.as_json,
        method => {
          first_name: 'Bill',
          last_name: 'Gates',
          updated_at: object.send(method).reload.updated_at.as_json,
          address: {
            street: 'wallstreet', zip: '666',
            city: 'atlantis', country: 'IT'
          }
        }
      },
                    resource: resource}.merge(eextra_args)).value!
    end

    it { expect(result3).to be_a resource.class }
    it { expect(result3.send(method)).to be_a PersonResource }
    it { expect(result3.send(method).first_name).to eq 'Bill' }
    it { expect(result3.send(method).last_name).to eq 'Gates' }
    it { expect(result3.send(method).address).to be_a AddressResource }
    it { expect(result3.send(method).address.street).to eq 'wallstreet' }

  end

end
