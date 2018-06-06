require 'buzzn/schemas/transactions/admin/localpool/create'

describe 'Schemas::Transactions::Admin::Localpool::Create' do

  subject { Schemas::Transactions::Admin::Localpool::Create }

  context 'without address' do

    let(:params) { {name: 'be there'} }

    it { expect(subject.({})).to be_failure }
    it { expect(subject.(params)).to be_success }
    it { expect(subject.(params).output).to eq params }
  end

  context 'with address' do

    let(:params) { {name: 'be there', address: {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'}} }

    it { expect(subject.({name: 'be here', address: {}})).to be_failure }
    it { expect(subject.(params)).to be_success }
    it { expect(subject.(params).output).to eq params }
  end

end
