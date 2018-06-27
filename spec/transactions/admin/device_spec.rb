require 'buzzn/transactions/admin/device/create'

describe Transactions::Admin::Device do

  entity(:input) do
    {
      law: :free,
      two_way_meter: :yes,
      two_way_meter_used: :yes,
      primary_energy: :bio_mass,
      commissioning: Date.today,
      kw_peak: 1.250,
      kwh_per_annum: 23.400
    }
  end

  context 'Create' do

    entity(:operator) { create(:account, :buzzn_operator) }

    entity(:resource) do
      create(:group, :localpool)
      Admin::LocalpoolResource.all(operator).first
    end

    entity(:transaction) do
      Transactions::Admin::Device::Create.new
    end

    entity(:result) do
      transaction.(params: input, resource: resource)
    end

    it { expect { transaction.(params: {}, resource: resource)}.to raise_error Buzzn::ValidationError }
    it { expect(result).to be_success }
    it { expect(result.value).to be_a Admin::DeviceResource }
    it { expect(result.value.watt_peak).to eq(1250)  }
    it { expect(result.value.watt_hour_pa).to eq(23400)  }

  end

  describe 'Update' do

    entity(:operator) { create(:account, :buzzn_operator) }

    entity(:resource) do
      create(:device, localpool: create(:group, :localpool))
      Admin::LocalpoolResource.all(operator).first.devices.first
    end

    entity(:transaction) do
      Transactions::Admin::Device::Update.new
    end

    entity(:result) do
      transaction.(params: input.merge(updated_at: resource.updated_at.as_json),
                   resource: resource)
    end

    it { expect { transaction.(params: {}, resource: resource)}.to raise_error Buzzn::ValidationError }
    it { expect(result).to be_success }
    it { expect(result.value.watt_peak).to eq(1250)  }
    it { expect(result.value.watt_hour_pa).to eq(23400)  }

  end
end
