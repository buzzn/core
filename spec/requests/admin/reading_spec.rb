# coding: utf-8
require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'readings' do

    entity(:localpool) { Fabricate(:localpool) }
    entity(:meter) {Fabricate(:meter) }
    entity(:register) do
      register = meter.registers.first
      register.update(group: localpool)
      register
    end
    entity!(:reading) { Fabricate(:single_reading, register: register)}

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve SingleReadingResource: permission denied for User: #{$user.id}" }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Reading::Single: bla-bla-blub not found by User: #{$admin.id}" }
        ]
      }
    end

    let(:wrong_json) do
      {
        "errors"=>[
          {"parameter"=>"date", "detail"=>"must be a date"},
          {"parameter"=>"raw_value", "detail"=>"must be a float"},
          {"parameter"=>"value", "detail"=>"must be a float"},
          {"parameter"=>"unit", "detail"=>"must be one of: Wh, W, m³"},
          {"parameter"=>"reason", "detail"=>"must be one of: IOM, COM1, COM2, ROM, PMR, COT, COS, CMP, COB"},
          {"parameter"=>"read_by", "detail"=>"must be one of: BN, SN, SG, VNB"},
          {"parameter"=>"quality", "detail"=>"must be one of: 20, 67, 79, 187, 220, 201"},
          {"parameter"=>"source", "detail"=>"must be one of: SM, MAN"},
          {"parameter"=>"status", "detail"=>"must be one of: Z83, Z84, Z86"}
        ]
      }
    end

    context 'POST' do

      it '422' do
        POST "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin,
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
          "type"=>'reading',
          "date"=>Date.new(2016, 2, 1).to_s,
          "raw_value"=>23.66,
          "value"=>500.0,
          "unit"=>'m³',
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
        POST "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin, new_reading

        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(result.delete('updated_at')).not_to be_nil
        expect(Reading::Single.find(id)).not_to be_nil
        expect(result.to_yaml).to eq created_json.to_yaml
      end
    end

    context 'GET' do

      let(:readings_json) do
        register.readings.collect do |reading|
          {
            "id"=>reading.id,
            "type"=>"reading",
            'updated_at'=>reading.updated_at.as_json,
            "date"=>reading.date.to_s,
            "raw_value"=>reading.raw_value,
            "value"=>reading.value,
            "unit"=>reading.attributes['unit'],
            'reason'=>reading.attributes['reason'],
            'read_by'=>reading.attributes['read_by'],
            'source'=>reading.attributes['source'],
            'quality'=>reading.attributes['quality'],
            'status'=>reading.attributes['status'],
            "comment"=>reading.comment,
            "updatable"=>false,
            "deletable"=>true
          }
        end
      end

      let(:reading_json) do
        {
          "id"=>reading.id,
          "type"=>"reading",
          'updated_at'=>reading.updated_at.as_json,
          "date"=>reading.date.to_s,
          "raw_value"=>reading.raw_value,
          "value"=>reading.value,
          "unit"=>reading.attributes['unit'],
          'reason'=>reading.attributes['reason'],
          'read_by'=>reading.attributes['read_by'],
          'source'=>reading.attributes['source'],
          'quality'=>reading.attributes['quality'],
          'status'=>reading.attributes['status'],
          "comment"=>reading.comment,
          "updatable"=>false,
          "deletable"=>true
        }
      end

      it '200 all' do
        GET "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings", $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(readings_json.to_yaml)
      end

      xit '403' do
        # TODO need user which can access localpool > meter > register but nor reading
        GET "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $user

        expect(response).to have_http_status(403)
        expect(json.to_yaml).to eq(denied_json.to_yaml)
      end

      it '404' do
        GET "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/bla-bla-blub", $admin

        expect(response).to have_http_status(404)
        expect(json.to_yaml).to eq(not_found_json.to_yaml)
      end

      it '200' do
        GET "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin

        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(reading_json.to_yaml)
      end
    end
    
    context 'DELETE' do

      xit '403' do
        # TODO need user which can access localpool > meter > register but nor reading
      end

      it '205' do
        count = Reading::Single.count
        reading = Fabricate(:single_reading, register: register)
        expect(Reading::Single.count).to eq count + 1
        
        DELETE "/test/#{localpool.id}/meters/#{meter.id}/registers/#{register.id}/readings/#{reading.id}", $admin

        expect(response).to have_http_status(200)
        expect(Reading::Single.count).to eq count
      end
    end
  end
end
