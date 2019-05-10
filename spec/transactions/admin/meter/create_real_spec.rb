require 'buzzn/transactions/admin/meter/create_real'

describe Transactions::Admin::Meter::CreateReal do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }
  let(:resource) do
    localpool.save
    localpoolr.meters_real
  end

  let(:meter_data) { build(:meter, :real) }

  let(:grid_consumption_register) { build(:meta, :grid_consumption) }

  let(:existing_grid_consumption_register) { create(:meta, :grid_consumption) }

  let(:market_location_id) do
    'DE133713371'
  end

  let(:metering_location_id) do
    'DE3214325843274587321943754543543'
  end

  let(:grid_consumption_register_params) do
    params = grid_consumption_register.attributes
    params = params.delete_if {|k, v| k.ends_with?('id')}
    params = params.delete_if {|k, v| v.nil? }
    params.delete('updated_at')
    params.delete('created_at')
    params['market_location_id'] = market_location_id
    params
  end

  let(:registers_params) do
    registers = []
    registers.append(grid_consumption_register_params)
    registers
  end

  let(:meter_params) do
    params = meter_data.attributes
    params = params.delete_if {|k, v| k.ends_with?('id')}
    params[:metering_location_id] = metering_location_id
    params.delete('updated_at')
    params.delete('created_at')
    params
  end

  let(:meter_create_params) do
    params = meter_params.dup
    params['registers'] = registers_params
    params
  end

  let(:meter_create_params_with_one_empty) do
    params = meter_params.dup
    params['registers'] = registers_params.append({})
    params
  end

  let(:meter_assign_params) do
    params = meter_params.dup
    params['registers'] = [{ :id => existing_grid_consumption_register.id }]
    params
  end

  context 'create register' do

    let(:result_meter) do
      Transactions::Admin::Meter::CreateReal.new.(resource: resource,
                                                  params: meter_create_params)
    end

    it 'creates' do
      expect(result_meter).to be_success
      expect(result_meter.value!).to be_a Meter::RealResource
      res = result_meter.value!
      expect(res.registers.count).to eql 1
      expect(res.metering_location_id).to eql metering_location_id
      expect(res.registers.first.meta.market_location).not_to be_nil
      expect(res.registers.first.meta.market_location.market_location_id).to eql market_location_id
    end

  end

  context 'assign register' do

    let(:result_meter) do
      Transactions::Admin::Meter::CreateReal.new.(resource: resource,
                                                  params: meter_assign_params)
    end

    it 'creates' do
      expect(result_meter).to be_success
      expect(result_meter.value!).to be_a Meter::RealResource
      res = result_meter.value!
      expect(res.registers.count).to eql 1
      expect(res.metering_location_id).to eql metering_location_id
    end

  end

  context 'assign emtpy register' do

    let(:result_meter) do
      Transactions::Admin::Meter::CreateReal.new.(resource: resource,
                                                  params: meter_create_params_with_one_empty)
    end

    it 'creates' do
      expect(result_meter).to be_success
      expect(result_meter.value!).to be_a Meter::RealResource
      res = result_meter.value!
      expect(res.registers.count).to eql 2
      expect(res.object.registers.first.meta).not_to be_nil
      expect(res.object.registers.second.meta).to be_nil
    end

  end

end
