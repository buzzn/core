require 'buzzn/transactions/admin/register/update_real'

describe Transactions::Admin::Register::UpdateReal, order: :defined do

  let(:operator) { create(:account, :buzzn_operator) }

  let(:group) do
    create(:group, :localpool)
  end

  let(:register_first) do
    create(:register, :real, meta: nil)
  end

  let(:register_second) do
    create(:register, :real)
  end

  let(:meter) do
    create(:meter, :real, group: group, registers: [register_first, register_second])
  end

  let(:localpool_resource) do
    group
    Admin::LocalpoolResource.all(operator).retrieve(group.id)
  end

  let(:register_first_resource)  { localpool_resource.meters.retrieve(meter.id).registers.retrieve(register_first.id) }
  let(:register_second_resource) { localpool_resource.meters.retrieve(meter.id).registers.retrieve(register_second.id) }

  context 'empty register' do
    context 'creation' do
      let(:grid_consumption_register) { build(:meta, :grid_consumption) }
      let(:market_location_id) do
        'DE133713371'
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
      let(:params) do
        {
          updated_at: register_first.updated_at.to_json,
          meta: grid_consumption_register_params
        }
      end

      let(:result) {Transactions::Admin::Register::UpdateReal.new.(resource: register_first_resource, params: params)}
      it 'works' do
        expect(result).to be_success
        value = result.value!
        expect(value).to be_a Register::RealResource
        expect(value.object.meta.name).to eql grid_consumption_register_params['name']
        register_first.reload
        expect(register_first.meta.id).not_to be_nil
      end
    end

    context 'assignment' do
      let(:register_meta) { create(:meta) }
      let(:params) do
        {
          updated_at: register_first.updated_at.to_json,
          meta: {
            id: register_meta.id
          }
        }
      end

      let(:result) {Transactions::Admin::Register::UpdateReal.new.(resource: register_first_resource, params: params)}

      it 'works' do
        expect(result).to be_success
        value = result.value!
        expect(value).to be_a Register::RealResource
        expect(value.object.meta.id).to eql register_meta.id
        register_first_resource.object.reload
        expect(register_first_resource.object.meta.id).to eql register_meta.id
      end

    end
  end

  context 'occupied register' do
    context 'creation' do
      let(:grid_consumption_register) { build(:meta, :grid_consumption) }
      let(:market_location_id) do
        'DE133713371'
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
      let(:params) do
        {
          updated_at: register_second.updated_at.to_json,
          meta: grid_consumption_register_params
        }
      end

      let(:result) {Transactions::Admin::Register::UpdateReal.new.(resource: register_second_resource, params: params)}

      it 'fails' do
        expect {result}.to raise_error Buzzn::ValidationError, '{:meta=>[{:id=>"old register_meta would orphan"}]}'
      end

      context('no orphan') do
        let(:another_register) do
          create(:register, :real, meta: register_second.meta)
        end
        let!(:another_meter) do
          create(:meter, :real, group: group, registers: [ another_register ])
        end

        it 'works' do
          expect(result).to be_success
          value = result.value!
          expect(value).to be_a Register::RealResource
          expect(value.object.meta.name).to eql grid_consumption_register_params['name']
        end

      end

    end

    context 'assignment' do
      let(:register_meta) { create(:meta) }
      let(:params) do
        {
          updated_at: register_second.updated_at.to_json,
          meta: {
            id: register_meta.id
          }
        }
      end

      let(:result) {Transactions::Admin::Register::UpdateReal.new.(resource: register_second_resource, params: params)}

      it 'fails' do
        expect {result}.to raise_error Buzzn::ValidationError, '{:meta=>[{:id=>"old register_meta would orphan"}]}'
      end

      context('no orphan') do
        let(:another_register) do
          create(:register, :real, meta: register_second.meta)
        end
        let!(:another_meter) do
          create(:meter, :real, group: group, registers: [ another_register ])
        end

        it 'works' do
          expect(result).to be_success
          value = result.value!
          expect(value).to be_a Register::RealResource
          expect(value.object.meta.id).to eql register_meta.id
        end
      end
    end

    context 'unassignment' do
      let(:params) do
        {
          updated_at: register_second.updated_at.to_json,
        }
      end

      let(:result) {Transactions::Admin::Register::UpdateReal.new.(resource: register_second_resource, params: params)}

      it 'fails' do
        expect {result}.to raise_error Buzzn::ValidationError, '{:meta=>[{:id=>"old register_meta would orphan"}]}'
      end

      context('no orphan') do
        let(:another_register) do
          create(:register, :real, meta: register_second.meta)
        end
        let!(:another_meter) do
          create(:meter, :real, group: group, registers: [ another_register ])
        end

        it 'works' do
          expect(result).to be_success
          value = result.value!
          expect(value).to be_a Register::RealResource
          expect(value.object.meta).to be_nil
        end
      end

    end
  end
end
