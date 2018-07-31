require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'meters as real' do

    entity(:group) do
      group = create(:group, :localpool)
      $user.person.reload.add_role(Role::GROUP_MEMBER, group)
      group
    end

    entity(:meter) do
      meter = create(:meter, :real, group: group)
      create(:contract, :localpool_powertaker,
             localpool: group,
             market_location: meter.registers.first.meta)
      meter
    end

    let(:expected_json) do
      {
        'id'=>meter.id,
        'type'=>'meter_real',
        'updated_at'=> meter.updated_at.as_json,
        'product_serialnumber'=>meter.product_serialnumber,
        'sequence_number' => meter.sequence_number,
        'datasource'=>meter.datasource.to_s,
        'updatable'=>true,
        'deletable'=>true,
        'product_name'=>meter.product_name,
        'manufacturer_name'=>meter.attributes['manufacturer_name'],
        'manufacturer_description'=>meter.attributes['manufacturer_description'],
        'location_description'=>meter.attributes['location_description'],
        'direction_number'=>meter.attributes['direction_number'],
        'converter_constant'=>meter.converter_constant,
        'ownership'=>meter.attributes['ownership'],
        'build_year'=>meter.build_year,
        'calibrated_until'=>meter.calibrated_until ? meter.calibrated_until.to_s : nil,
        'edifact_metering_type'=>meter.attributes['edifact_metering_type'],
        'edifact_meter_size'=>meter.attributes['edifact_meter_size'],
        'edifact_tariff'=>meter.attributes['edifact_tariff'],
        'edifact_measurement_method'=>meter.attributes['edifact_measurement_method'],
        'edifact_mounting_method'=>meter.attributes['edifact_mounting_method'],
        'edifact_voltage_level'=>meter.attributes['edifact_voltage_level'],
        'edifact_cycle_interval'=>meter.attributes['edifact_cycle_interval'],
        'edifact_data_logging'=>meter.attributes['edifact_data_logging'],
        'sent_data_dso'=>meter.sent_data_dso.to_s,
      }
    end

    context 'GET' do

      it '401' do
        GET "/localpools/#{group.id}/meters/#{meter.id}", $admin
        expire_admin_session do
          GET "/localpools/#{group.id}/meters/#{meter.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/localpools/#{group.id}/meters/#{meter.id}", $user
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/localpools/#{group.id}/meters/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{group.id}/meters/#{meter.id}", $admin, include: 'registers:[market_location:[contracts:[customer]]]'

        expect(json).to has_nested_json(:registers, :array, :market_location, :contracts, :array, :customer, :id)

        result = json
        result.delete('registers')
        expect(response).to have_http_status(200)
        expect(result.to_yaml).to eq expected_json.to_yaml
      end
    end

    context 'PATCH' do

      entity(:real_meter) { create(:meter, :real, group: group) }

      let(:wrong_json) do
        {
          'product_serialnumber'=>['size cannot be greater than 128'],
          'datasource'=>['must be one of: standard_profile, discovergy, virtual'],
          'product_name'=>['size cannot be greater than 64'],
          'manufacturer_name'=>['must be one of: easy_meter, other'],
          'build_year'=>['must be an integer'],
          'sent_data_dso'=>['must be a date'],
          'converter_constant'=>['must be an integer'],
          'calibrated_until'=>['must be a date'],
          'direction_number'=>['must be one of: ERZ, ZRZ'],
          'edifact_metering_type'=>['must be one of: AHZ, WSZ, LAZ, MAZ, EHZ, IVA'],
          'edifact_meter_size'=>['must be one of: Z01, Z02, Z03'],
          'edifact_measurement_method'=>['must be one of: AMR, MMR'],
          'edifact_tariff'=>['must be one of: ETZ, ZTZ, NTZ'],
          'edifact_mounting_method'=>['must be one of: BKE, DPA, HS'],
          'edifact_voltage_level'=>['must be one of: E06, E05, E04, E03'],
          'edifact_cycle_interval'=>['must be one of: MONTHLY, QUARTERLY, HALF_YEARLY, YEARLY'],
          'edifact_data_logging'=>['must be one of: Z04, Z05'],
          'updated_at'=>['is missing']
        }
      end

      let(:updated_json) do
        meter = real_meter
        {
          'id'=>meter.id,
          'type'=>'meter_real',
          'product_serialnumber'=>'12341234',
          'sequence_number' => meter.sequence_number,
          'datasource'=>'standard_profile',
          'updatable'=>true,
          'deletable'=>true,
          'product_name'=>'Smarty Super Meter',
          'manufacturer_name'=>'other',
          'manufacturer_description'=>'Manufacturer description',
          'location_description'=>'Location description',
          'direction_number'=>'ZRZ',
          'converter_constant'=>20,
          'ownership'=>'CUSTOMER',
          'build_year'=>2017,
          'calibrated_until'=>Date.today.to_s,
          'edifact_metering_type'=>'EHZ',
          'edifact_meter_size'=>'Z02',
          'edifact_tariff'=>'ZTZ',
          'edifact_measurement_method'=>'MMR',
          'edifact_mounting_method'=> 'HS',
          'edifact_voltage_level'=>'E04',
          'edifact_cycle_interval'=>'QUARTERLY',
          'edifact_data_logging'=>'Z04',
          'sent_data_dso'=>'2010-01-01'
        }
      end

      it '401' do
        GET "/localpools/#{group.id}/meters/#{real_meter.id}", $admin
        expire_admin_session do
          PATCH "/localpools/#{group.id}/meters/#{real_meter.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        PATCH "/localpools/#{group.id}/meters/#{real_meter.id}", $user
        expect(response).to have_http_status(403)
      end

      it '404' do
        PATCH "/localpools/#{group.id}/meters/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '409' do
        meter = real_meter
        PATCH "/localpools/#{group.id}/meters/#{meter.id}", $admin,
              updated_at: DateTime.now
        expect(response).to have_http_status(409)
      end

      it '422' do
        meter = real_meter
        PATCH "/localpools/#{group.id}/meters/#{meter.id}", $admin,
              datasource: 'mysmartgrid',
              manufacturer_name: 'Maxima' * 20,
              product_name: 'SmartyMeter' * 10,
              product_serialnumber: '12341234' * 20,
              onwership: 'me',
              build_year: 'this-year',
              sent_data_dso: 'some-years-ago',
              converter_constant: 'convert-it',
              calibrated_until: 'today',
              edifact_metering_type: 'sometype',
              edifact_meter_size: 'somesize',
              edifact_measurement_method: 'some' * 60,
              edifact_tariff: 'something',
              edifact_mounting_method: 'something',
              edifact_voltage_level: 'something',
              edifact_cycle_interval: 'something',
              edifact_data_logging: 'something',
              direction_number: 'uni'

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '200' do
        meter = real_meter
        old = meter.updated_at
        PATCH "/localpools/#{group.id}/meters/#{meter.id}", $admin,
              updated_at: meter.updated_at,
              datasource: 'standard_profile',
              manufacturer_name: Meter::Real.manufacturer_names[:other],
              manufacturer_description: 'Manufacturer description',
              location_description: 'Location description',
              product_name: 'Smarty Super Meter',
              product_serialnumber: '12341234',
              ownership: Meter::Real.ownerships[:customer],
              build_year: 2017,
              sent_data_dso: '2010-01-01',
              converter_constant: 20,
              calibrated_until: Date.today,
              edifact_metering_type: Meter::Real.edifact_metering_types[:digital_household_meter],
              edifact_meter_size: Meter::Real.edifact_meter_sizes[:edl21],
              edifact_measurement_method: Meter::Real.edifact_measurement_methods[:manual],
              edifact_tariff: Meter::Real.edifact_tariffs[:dual_tariff],
              edifact_mounting_method: Meter::Real.edifact_mounting_methods[:cap_rail],
              edifact_voltage_level: Meter::Real.edifact_voltage_levels[:high_level],
              edifact_cycle_interval: Meter::Real.edifact_cycle_intervals[:quarterly],
              edifact_data_logging: Meter::Real.edifact_data_loggings[:analog],
              direction_number: Meter::Real.direction_numbers[:two_way_meter]

        expect(response).to have_http_status(200)
        meter.reload
        expect(meter.manufacturer_name).to eq 'other'
        expect(meter.manufacturer_description).to eq 'Manufacturer description'
        expect(meter.location_description).to eq 'Location description'
        expect(meter.direction_number).to eq 'two_way_meter'
        expect(meter.ownership).to eq 'customer'
        expect(meter.build_year).to eq 2017
        expect(meter.sent_data_dso).to eq Date.new(2010)
        expect(meter.converter_constant).to eq 20
        expect(meter.calibrated_until).to eq Date.today
        expect(meter.edifact_metering_type).to eq 'digital_household_meter'
        expect(meter.edifact_meter_size).to eq 'edl21'
        expect(meter.edifact_measurement_method).to eq 'manual'
        expect(meter.edifact_tariff).to eq 'dual_tariff'
        expect(meter.edifact_mounting_method).to eq 'cap_rail'
        expect(meter.edifact_voltage_level).to eq 'high_level'
        expect(meter.edifact_cycle_interval).to eq 'quarterly'
        expect(meter.edifact_data_logging).to eq 'analog'
        expect(meter.product_name).to eq 'Smarty Super Meter'
        expect(meter.product_serialnumber).to eq '12341234'

        result = json
        # TODO fix it: our time setup does not allow
        #expect(result.delete('updated_at')).to be > old.as_json
        expect(result.delete('updated_at')).not_to eq old.as_json
        expect(result.to_yaml).to eq updated_json.to_yaml
      end
    end
  end
end
