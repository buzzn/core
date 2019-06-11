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

      let(:params) do
        {
          content: 'changed',
          updated_at: contract.updated_at.to_json
        }
      end

      let(:contract) do
        create(:contract, ctype, localpool: localpool)
      end

      let(:result) do
        Transactions::Admin::Comment::Update.new.(params: params, resource: resource)
      end

      it 'updates' do
        expect(result).to be_success
        res = result.value!
        resource.object.reload
        expect(resource.object.content).to eql 'changed'
      end

    end

  end
end
