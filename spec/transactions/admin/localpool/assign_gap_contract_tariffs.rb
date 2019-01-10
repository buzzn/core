describe Transactions::Admin::Localpool::AssignGapContractTariffs, order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:today) do
    Date.today
  end

  let!(:tariff_1) do
    create(:tariff, group: localpool, begin_date: today)
  end

  let!(:tariff_2) do
    create(:tariff, group: localpool, begin_date: today+30)
  end

  let!(:tariff_3) do
    create(:tariff, group: localpool, begin_date: today+32)
  end

  let!(:tariff_4) do
    create(:tariff, group: localpool, begin_date: today)
  end

  let(:resource) do
    localpoolr
  end

  context 'with a valid tariff combination' do
    let(:params) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [tariff_1.id, tariff_2.id]
      }
    end

    let(:result) do
      Transactions::Admin::Localpool::AssignGapContractTariffs.new.(params: params,
                                                                    resource: resource)
    end

    it 'assigns' do
      expect(localpool.gap_contract_tariffs.pluck(:id)).to eql []
      expect(result).to be_success
      localpool.reload
      expect(localpool.gap_contract_tariffs.pluck(:id)).to eql [tariff_1.id, tariff_2.id]
    end

  end

end
