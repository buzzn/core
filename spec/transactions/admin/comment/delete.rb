describe Transactions::Admin::Comment::Update do
  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let(:comment) { create(:comment) }

  let(:params) do
    {
      content: 'changed',
      updated_at: comment.updated_at.to_json
    }
  end

  let(:result) do
    Transactions::Admin::Comment::Delete.new.(resource: resource)
  end

  context 'meter' do

    before do
      meter.comments << comment
    end

    let(:meter) do
      create(:meter, :real, group: localpool)
    end

    let(:resource) do
      Admin::LocalpoolResource.all(operator).retrieve(localpool.id).meters.retrieve(meter.id).comments.retrieve(comment.id)
    end

    it 'deletes' do
      old_count = meter.comments.count
      expect(result).to be_success
      meter.reload
      expect(meter.comments.count).to eql old_count-1
    end

  end

  context 'localpool' do
    before do
      localpool.comments << comment
    end

    let(:resource) do
      Admin::LocalpoolResource.all(operator).retrieve(localpool.id).comments.retrieve(comment.id)
    end

    it 'deletes' do
      old_count = localpool.comments.count
      expect(result).to be_success
      localpool.reload
      expect(localpool.comments.count).to eql old_count-1
    end

  end

  [:localpool_processing, :localpool_powertaker, :metering_point_operator].each do |ctype|
    context "#{ctype}" do

      before do
        contract.comments << comment
      end

      let(:resource) do
        Admin::LocalpoolResource.all(operator).retrieve(localpool.id).contracts.retrieve(contract.id).comments.first
      end

      let(:contract) do
        create(:contract, ctype, localpool: localpool)
      end

      it 'deletes' do
        old_count = contract.comments.count
        expect(result).to be_success
        localpool.reload
        expect(contract.comments.count).to eql old_count-1
      end

    end

  end
end
