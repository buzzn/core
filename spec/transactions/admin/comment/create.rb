describe Transactions::Admin::Comment::Create do
  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }

  [:localpool_processing, :localpool_powertaker, :metering_point_operator].each do |ctype|
    context "#{ctype}" do
      let(:params) do
        {
          content: 'comment comment comment',
          author: 'me'
        }
      end

      let(:contract) do
        create(:contract, ctype, localpool: localpool)
      end

      let(:resource) do
        Admin::LocalpoolResource.all(operator).retrieve(localpool.id).contracts.retrieve(contract.id).comments
      end

      let(:result) do
        Transactions::Admin::Comment::Create.new.(params: params, resource: resource)
      end

      it 'creates' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Admin::CommentResource
      end
    end
  end

end
