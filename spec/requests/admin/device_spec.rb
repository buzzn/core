# coding: utf-8
require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'devices', :order => :defined do

    entity(:localpool) { create(:group, :localpool) }

    entity(:id) { '' }

    let(:path) {"/localpools/#{localpool.id}/devices/#{id}" }

    let(:wrong) do
      {
        'primary_energy'=> :free_will,
        'commissioning'=> :tomorrow,
        'manufacturer' => 'GummiBar' * 40,
        'kw_peak'=> 'infinity',
        'kwh_per_annum'=> 'infinity'
      }
    end

    let(:wrong_json) do
      { 'errors'=>{'primary_energy'=>['must be one of: bio_mass, bio_gas, natural_gas, fluid_gas, fuel_oil, wood, veg_oil, sun, wind, water, other'],
        'commissioning'=>['must be a date'],
        'manufacturer' => ['size cannot be greater than 64'],
        'kw_peak'=>['must be a float'],
        'kwh_per_annum'=>['must be a float']}
      }
    end

    let(:created_json) do
      {
        'type'=>'device',
        'primary_energy'=> 'sun',
        'commissioning'=> Date.today.as_json,
        'kw_peak'=> 32.42,
        'kwh_per_annum'=> 3.122,
        'law' => 'free',
        'manufacturer' => 'GummiBär',
        'name' => 'The big one',
        'model' => '3000',
        'updatable'=>true,
        'deletable'=>true
      }
    end

    context 'POST' do
      
      it_behaves_like 'create', Device,
                      path: :path,
                      wrong: :wrong,
                      params: {
                        'primary_energy'=> 'sun',
                        'manufacturer' => 'GummiBär',
                        'model' => '3000',
                        'commissioning'=> Date.today.as_json,
                        'kw_peak'=> 32.42,
                        'kwh_per_annum'=> 3.122,
                        'law' => 'free',
                        'name' => 'The big one',
                      },
                      errors: :wrong_json,
                      expected: :created_json

      after do
        device = Device.all.first
        id.replace(device.id.to_s) if device
      end

    end

    let(:device) { Device.find(id) }

    context 'GET' do

      let(:device_json) do
        created_json.merge(
          'id'=>id.to_i,
          'created_at' => device.created_at.as_json,
          'updated_at' => device.updated_at.as_json,
          'updatable' => true,
          'deletable' => true
        )
      end

      it_behaves_like 'single', :device, expected: :device_json, path: :path
      it_behaves_like 'all', expected: :device_json, path: :path

    end

    context 'PATCH' do

      let(:wrong_update) do
        wrong.merge(updated_at: device.updated_at.as_json)
      end

      let(:input) do
        {
          'primary_energy'=> 'wind',
          'manufacturer' => 'RubberBear',
          'commissioning'=> (Date.today + 1).as_json,
          'law' => 'eeg'
        }
      end

      let(:updated_json) do
        created_json.merge(input)
      end

      it_behaves_like 'update', :device,
                      path: :path,
                      wrong: :wrong_update,
                      params: :input,
                      errors: :wrong_json,
                      expected: :updated_json

    end

    context 'DELETE' do
      it_behaves_like 'delete', :device, path: :path
    end
  end
end
