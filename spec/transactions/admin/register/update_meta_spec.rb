require 'buzzn/transactions/admin/register/update_meta'

describe Transactions::Admin::Register::UpdateMeta, order: :defined do

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:group) do
    create(:group, :localpool)
  end

  entity(:meter) do
    create(:meter, :real, group: group)
  end

  entity(:register_meta) do
    meter.registers.first.meta
  end

  let(:localpool_resource) { Admin::LocalpoolResource.all(operator).first }
  let(:register_meta_resource) { localpool_resource.register_metas.retrieve(register_meta.id) }

  let(:updated_params_base) do
    register_meta.reload
    mjson = register_meta.attributes
    mjson.delete('created_at')
    mjson.delete('id')
    mjson.delete('last_observed')
    mjson['updated_at'] = register_meta.updated_at.as_json
    unless mjson['market_location_id'].nil?
      mjson['market_location_id'] = Register::MarketLocation.find_by_id(mjson['market_location_id']).market_location_id
    end
    mjson
  end

  let(:market_location_id) do
    'DE133713371'
  end

  let(:updated_params_market_location_id) do
    register_meta.reload
    mjson = updated_params_base.dup
    mjson[:updated_at] = register_meta.updated_at.as_json
    mjson[:market_location_id] = market_location_id
    mjson
  end

  let(:identity_result) do
    Transactions::Admin::Register::UpdateMeta.new.(params: updated_params_base, resource: register_meta_resource)
  end

  let(:market_location_result) do
    Transactions::Admin::Register::UpdateMeta.new.(params: updated_params_market_location_id, resource: register_meta_resource)
  end

  context 'identity' do
    it 'updates' do
      expect(identity_result).to be_success
    end
  end

  context 'market_location' do
    it 'updates' do
      expect(market_location_result).to be_success
      register_meta.reload
      expect(register_meta.market_location.market_location_id).to eql market_location_id
    end
  end

end
