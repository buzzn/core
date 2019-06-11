describe Transactions::Admin::Comment::Update do
  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }

  [:localpool_processing, :localpool_powertaker, :metering_point_operator].each do |ctype|
    context "#{ctype}" do

      before do
        contract.comments.create(content: 'unchanged', author: 'me')
      end

      let(:resource) do
        Admin::LocalpoolResource.all(operator).retrieve(localpool.id).contracts.retrieve(contract.id).comments.first
      end

      let(:contract) do
        create(:contract, ctype, localpool: localpool)
      end

      let(:result) do
        Transactions::Admin::Comment::Delete.new.(resource: resource)
      end

      it 'deletes' do
        expect(result).to be_success
      end

    end

  end
end
