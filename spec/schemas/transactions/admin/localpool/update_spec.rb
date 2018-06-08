require 'buzzn/schemas/transactions/admin/localpool/update'

describe 'Schemas::Transactions::Admin::Localpool::Update' do

  subject { Schemas::Transactions::Admin::Localpool::Update }

  let(:localpool_params) { {name: 'be there', updated_at: Date.today.as_json} }

  context 'without address' do

    it { expect(subject.({})).to be_failure }
    it { expect(subject.(localpool_params)).to be_success }
    it { expect(subject.(localpool_params).output).to eq localpool_params }
  end

  context 'with address' do

    let(:params) do
      localpool_params.merge(address: {street: 'wallstreet',
                                       zip: '666',
                                       city: 'atlantis',
                                       country: 'IT',
                                       updated_at: Date.today.as_json})
    end

    it { expect(subject.(localpool_params.merge(address: {}))).to be_failure }
    it { expect(subject.(params)).to be_success }
    it { expect(subject.(params).output).to eq params }
  end

end
