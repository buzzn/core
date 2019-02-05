# coding: utf-8
require_relative 'test_admin_localpool_roda'

describe Admin::LocalpoolRoda, :request_helper, order: :defined do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'readings' do

    entity(:localpool) { create(:group, :localpool) }
    entity(:meter)     { create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool) }
    entity(:register)  { meter.registers.first }
    entity!(:reading)  { create(:reading, register: register, value: 10, raw_value: 10)}

    let(:wrong_json) do
      {
        'raw_value'=>['must be an integer'],
        'value'=>['must be an integer'],
        'unit'=>['must be one of: Wh, W, m³'],
        'reason'=>['must be one of: IOM, COM1, COM2, ROM, PMR, COT, COS, CMP, COB'],
        'read_by'=>['must be one of: BN, SN, SG, VNB'],
        'quality'=>['must be one of: 20, 67, 79, 187, 220, 201'],
        'source'=>['must be one of: SM, MAN'],
        'status'=>['must be one of: Z83, Z84, Z86'],
        'date'=>['must be a date']
      }
    end

    context 'request' do
      before(:each) do
        Import.global('services.redis_cache').flushall
      end
      let(:now) do
        Date.today.to_time
      end
      let(:params) do
        {
          date: now.to_json
        }
      end
      entity(:single_reading) do
        Import.global('services.datasource.discovergy.single_reading')
      end

      context 'READ' do

        it '403' do
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/read"
          expect(response).to have_http_status(403)
        end

        it '422' do
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/read", $admin
          expect(response).to have_http_status(422)
        end

        it 'works and produces 201' do
          mock_series_start = create_series(now-5.minutes, 2000, 15.minutes, 10*1000*1000, 50*1000*1000, 4)
          single_reading.next_api_request_single(register, now, mock_series_start)
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/read", $admin, params
          expect(response).to have_http_status(201)
        end

        it 'it produces an 404 when no readings are found' do
          single_reading.next_api_request_single(register, now, [])
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/read", $admin, params
          expect(response).to have_http_status(404)
        end

        context 'already present' do
          it 'it produces an 422 when if there are already reading' do
            another_reading = create(:reading, register: register, date: now)
            mock_series_start = create_series(now-5.minutes, 2000, 15.minutes, 10*1000*1000, 50*1000*1000, 4)
            single_reading.next_api_request_single(register, now, mock_series_start)
            POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/read", $admin, params
            expect(response).to have_http_status(422)
            another_reading.destroy
          end
        end

      end

      context 'CREATE' do

        it '403' do
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/create"
          expect(response).to have_http_status(403)
        end

        it '422' do
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/create", $admin
          expect(response).to have_http_status(422)
        end

        it 'works' do
          mock_series_start = create_series(now-5.minutes, 2000, 15.minutes, 20*10*1000*1000, 50*1000*1000, 4)
          single_reading.next_api_request_single(register, now, mock_series_start)
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/request/create", $admin, params
          expect(response).to have_http_status(201)
        end

      end

    end

    context 'POST' do

      it '401' do
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin
        expire_admin_session do
          POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '422' do
        POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin,
             date: 'today',
             raw_value: 'unknown',
             value: 'infinity',
             unit: 'spice',
             reason: 'just',
             read_by: 'nobody',
             source: 'imagination',
             quality: 'best',
             status: 'set',
             comment: 'the sun is shining'

        expect(json.to_yaml).to eq wrong_json.to_yaml
        expect(response).to have_http_status(422)
      end

      let(:created_json) do
        {
          'type'=>'reading',
          'date'=>Date.new(2018, 2, 1).to_s,
          'raw_value'=>19,
          'value'=>19,
          'unit'=>'m³',
          'reason'=>'IOM',
          'read_by'=>'BN',
          'source'=>'MAN',
          'quality'=>'201',
          'status'=>'Z86',
          'comment'=>'yellow is the new green',
          'updatable'=>false,
          'deletable'=>true
        }
      end

      let(:new_reading) do
        json = created_json.dup
        json.delete('type')
        json.delete('updatable')
        json.delete('deletable')
        json
      end

      it '201' do
        POST "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin, new_reading

        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(result.delete('updated_at')).not_to be_nil
        expect(result.delete('created_at')).not_to be_nil
        expect(Reading::Single.find(id)).not_to be_nil
        expect(result.to_yaml).to eq created_json.to_yaml
      end
    end

    context 'GET' do

      let(:readings_json) do
        register.readings.collect do |reading|
          {
            'id'=>reading.id,
            'type'=>'reading',
            'created_at'=>reading.created_at.as_json,
            'updated_at'=>reading.updated_at.as_json,
            'date'=>reading.date.to_s,
            'raw_value'=>reading.raw_value,
            'value'=>reading.value,
            'unit'=>reading.attributes['unit'],
            'reason'=>reading.attributes['reason'],
            'read_by'=>reading.attributes['read_by'],
            'source'=>reading.attributes['source'],
            'quality'=>reading.attributes['quality'],
            'status'=>reading.attributes['status'],
            'comment'=>reading.comment,
            'updatable'=>false,
            'deletable'=>true
          }
        end
      end

      let(:reading_json) do
        {
          'id'=>reading.id,
          'type'=>'reading',
          'created_at'=>reading.created_at.as_json,
          'updated_at'=>reading.updated_at.as_json,
          'date'=>reading.date.to_s,
          'raw_value'=>reading.raw_value,
          'value'=>reading.value,
          'unit'=>reading.attributes['unit'],
          'reason'=>reading.attributes['reason'],
          'read_by'=>reading.attributes['read_by'],
          'source'=>reading.attributes['source'],
          'quality'=>reading.attributes['quality'],
          'status'=>reading.attributes['status'],
          'comment'=>reading.comment,
          'updatable'=>false,
          'deletable'=>true
        }
      end

      it '200 all' do
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(readings_json.to_yaml)
      end

      it '401' do
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin
        expire_admin_session do
          GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      xit '403' do
        # TODO need user which can access localpool > meter > register but nor reading
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $user

        expect(response).to have_http_status(403)
        expect(json.to_yaml).to eq(denied_json.to_yaml)
      end

      it '404' do
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin

        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(reading_json.to_yaml)
      end
    end

    context 'DELETE' do

      it '401' do
        GET "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin
        expire_admin_session do
          DELETE "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      xit '403' do
        # TODO need user which can access localpool > meter > register but nor reading
      end

      it '204' do
        count = Reading::Single.count
        reading = create(:reading, register: register, date: Date.today)
        expect(Reading::Single.count).to eq count + 1

        DELETE "/localpools/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin

        expect(response).to have_http_status(204)
        expect(Reading::Single.count).to eq count
      end
    end
  end
end
