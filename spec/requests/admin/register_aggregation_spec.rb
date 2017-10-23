require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:discovergy_meter) do
    meter = Fabricate(:easymeter_60139082) # in_out meter
    # TODO what to do with the in-out fact ?
    Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_60139082", mode: :in_out)
    meter
  end

  let(:input_register) { discovergy_meter.input_register }

  let(:output_register) { discovergy_meter.output_register }

  entity(:slp_register) { Fabricate(:input_meter).input_register }

  entity(:sep_register) { Fabricate(:output_meter).output_register }

  entity(:group) do
    group = Fabricate(:localpool)
    group.registers += discovergy_meter.registers
    group.registers += [slp_register, sep_register]
    group
  end

  let(:time) { Time.find_zone('Berlin').local(2016, 2, 1, 1, 30, 1) }

  context 'registers' do
    context 'ticker' do

      let(:out_json) do
        { "timestamp" => 1467446702.088,
          "value" => 1200640.0,
          "resource_id" => output_register.id,
          "mode" => "out",
          "expires_at"=> 1454286616.0 }
      end

      let(:in_json) do
        { "timestamp" => 1467446702.088,
          "value" => 1100640.0,
          "resource_id" => input_register.id,
          "mode" => "in",
          "expires_at"=> 1454286616.0 }
      end

      let(:slp_json) do
        { "timestamp" => 1454287500.0,
          "value" => 930007.0,
          "resource_id" => slp_register.id,
          "mode"=>"in",
          # last_readings + 15.minutes - 1 (as time is 01:30:01)
          "expires_at"=> (time + 15.minutes - 1).to_f }
      end

      context 'GET' do

        it '200 discovergy' do
          VCR.use_cassette("request/api/v1/discovergy") do

            time = Time.find_zone('Berlin').local(2016, 2, 1, 1, 30, 1)
            begin
              Timecop.freeze(time)

              GET "/test/#{group.id}/registers/#{input_register.id}/ticker", $admin

              expect(response).to have_http_status(200)
              expect(json).to eq(in_json)
              expect(response.headers['Expires']).not_to be_nil
              expect(response.headers['Cache-Control']).to eq "private, max-age=15"
              expect(response.headers['ETag']).not_to be_nil
              expect(response.headers['Last-Modified']).not_to be_nil

              GET "/test/#{group.id}/registers/#{output_register.id}/ticker", $admin

              expect(response).to have_http_status(200)
              expect(json).to eq(out_json)
              expect(expires = response.headers['Expires']).not_to be_nil
              expect(response.headers['Cache-Control']).to eq "private, max-age=15"
              expect(etag = response.headers['ETag']).not_to be_nil
              expect(modified = response.headers['Last-Modified']).not_to be_nil

              # cache hit
              Timecop.freeze(time + 5)
              GET "/test/#{group.id}/registers/#{output_register.id}/ticker", $admin

              expect(response).to have_http_status(200)
              expect(json).to eq(out_json)
              expect(response.headers['Expires']).to eq expires
              expect(response.headers['ETag']).to eq etag
              expect(response.headers['Last-Modified']).to eq modified

              # no cache hit
              Timecop.freeze(time + 25)
              GET "/test/#{group.id}/registers/#{output_register.id}/ticker", $admin

              expect(response).to have_http_status(200)
              expect(json).to eq({ "timestamp" => 1467446702.188,
                                   "value" => 0.0,
                                   "resource_id" => output_register.id,
                                   "mode" => "out",
                                   "expires_at" => 1454286641.0 })
              expect(response.headers['Expires']).not_to eq expires
              expect(response.headers['ETag']).not_to eq etag
              expect(response.headers['Last-Modified']).not_to eq modified
            ensure
              Timecop.return
            end
          end
        end

        it '200 standard profile' do
          Reading::Continuous.all.delete_all
          timestamp = Time.find_zone('Berlin').local(2016, 2, 1)
          40.times do |i|
            Fabricate(:reading,
                      source: Reading::Continuous::SLP,
                      timestamp: timestamp,
                      power_milliwatt: 930000 + i,
                      reason: Reading::Continuous::REGULAR_READING,
                      quality: Reading::Continuous::READ_OUT,
                      energy_milliwatt_hour: (1 + i)*10000,
                      meter_serialnumber: '12346578'
                     )
            timestamp += 15.minutes
          end

          begin
            Timecop.freeze(time)

            GET "/test/#{group.id}/registers/#{slp_register.id}/ticker", $admin

            expect(response).to have_http_status(200)
            expect(json).to eq(slp_json)
            expect(response.headers['Expires']).not_to be_nil
            # - 1 minute see 'time' and when readings were created
            expect(response.headers['Cache-Control']).to eq "private, max-age=899"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil

            GET "/test/#{group.id}/registers/#{slp_register.id}/ticker", $admin

            expect(response).to have_http_status(200)
            expect(json).to eq(slp_json)
            expect(response.headers['Expires']).not_to be_nil
            # - 1 minute see 'time' and when readings were created
            expect(response.headers['Cache-Control']).to eq "private, max-age=899"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil
          ensure
            Timecop.return
          end
        end

        xit '200 virtual' do
        end
      end
    end

    context 'charts' do

      let(:hour_json) do
        { "units" => "milliwatt",
          "resource_id" => input_register.id,
          "in" => [{"timestamp" => 1467446702.088, "value" => 1100640.0},
                   {"timestamp" => 1467446702.288, "value" => 1100740.0}],
          "out" => []
        }
      end

      let(:day_json) do
        { "units" => "milliwatt",
          "resource_id" => output_register.id,
          "out"=>[{"timestamp" => 1483225200.0, "value" => 511856.2932},
                  {"timestamp" => 1483226100.0, "value" => 540135.0148},
                  {"timestamp" => 1483227000.0, "value" => 614257.786},
                  {"timestamp" => 1483227900.0, "value" => 538366.4216}],
          "in" => []
        }
      end

      let(:yesterday_json) do
        { "units"=>"milliwatt",
          "resource_id" => input_register.id,
          "in" => [{"timestamp" => 1483138800.0, "value" => 882855.2836},
                   {"timestamp" => 1483139700.0, "value" => 305943.0632},
                   {"timestamp" => 1483140600.0, "value" => 896316.3292},
                   {"timestamp" => 1483141500.0, "value" => 894245.9292}],
          "out" => []
        }
      end

      let(:month_json) do
        { "units" => "milliwatt_hour",
          "resource_id" => output_register.id,
          "in" => [],
          "out" => [{"timestamp" => 1483225200.0, "value" => 17309965.2674},
                    {"timestamp" => 1483311600.0, "value" => 26111829.0018}]
        }
      end

      let(:year_json) do
        { "units" => "milliwatt_hour",
          "resource_id" => input_register.id,
          "in" => [{"timestamp" => 1483225200.0, "value" => 21179442.0026},
                   {"timestamp" => 1483311600.0, "value" => 21232911.5229}],
          "out" => []
        }
      end

      let(:missing_json) do
        {
          "errors" => [{"parameter" => "duration",
                        "detail" => "is missing"}]
        }
      end

      let(:invalid_json) do
        {
          "errors" => [{"parameter" => "duration",
                        "detail" => "must be one of: year, month, day, hour"}]
        }
      end

      context 'GET' do

        it '422 missing duration' do
          GET "/test/#{group.id}/registers/#{input_register.id}/charts", $admin
          expect(response).to have_http_status(422)
          expect(json).to eq missing_json
        end

        it '422 wrong duration' do
          GET "/test/#{group.id}/registers/#{input_register.id}/charts", $admin, duration: :century
          expect(response).to have_http_status(422)
          expect(json).to eq invalid_json
        end

        it '200 discovergy' do
          VCR.use_cassette("request/api/v1/discovergy") do

            begin
              Timecop.freeze(time)

              GET "/test/#{group.id}/registers/#{input_register.id}/charts", $admin, duration: :hour

              expect(response).to have_http_status(200)
              expect(json).to eq(hour_json)
              expect(response.headers['Cache-Control']).to eq "private, max-age=15"
              expect(response.headers['ETag']).not_to be_nil
              expect(response.headers['Last-Modified']).not_to be_nil

              GET  "/test/#{group.id}/registers/#{output_register.id}/charts", $admin, duration: :day

              expect(response).to have_http_status(200)
              expect(json).to eq(day_json)
              expect(response.headers['Cache-Control']).to eq "private, max-age=900"
              expect(response.headers['ETag']).not_to be_nil
              expect(response.headers['Last-Modified']).not_to be_nil

              GET  "/test/#{group.id}/registers/#{input_register.id}/charts", $admin, duration: :day, timestamp: time - 1.day

              expect(response).to have_http_status(200)
              expect(json).to eq(yesterday_json)
              expect(response.headers['Cache-Control']).to eq "private, max-age=86400"
              expect(response.headers['ETag']).not_to be_nil
              expect(response.headers['Last-Modified']).not_to be_nil

              GET  "/test/#{group.id}/registers/#{output_register.id}/charts", $admin, duration: :month

              expect(response).to have_http_status(200)
              expect(json).to eq(month_json)
              expect(response.headers['Cache-Control']).to eq "private, max-age=3600"
              expect(response.headers['ETag']).not_to be_nil
              expect(response.headers['Last-Modified']).not_to be_nil

              GET  "/test/#{group.id}/registers/#{input_register.id}/charts", $admin, duration: :year

              expect(json).to eq(year_json)
              expect(response).to have_http_status(200)
              expect(response.headers['Cache-Control']).to eq "private, max-age=86400"
              expect(response.headers['ETag']).not_to be_nil
              expect(response.headers['Last-Modified']).not_to be_nil
            ensure
              Timecop.return
            end
          end
        end

        let(:setup_readings) do
          timestamp = Time.find_zone('UTC').local(2016, 2, 1)
          energy = 0
          40.times do |i|
            Fabricate(:reading,
                      source: [Reading::Continuous::SLP, Reading::Continuous::SEP_BHKW][i % 2],
                      timestamp: timestamp,
                      energy_milliwatt_hour: energy,
                      power_milliwatt: 930000 + i,
                      reason: Reading::Continuous::REGULAR_READING,
                      quality: Reading::Continuous::READ_OUT,
                      meter_serialnumber: '12346578'
                     )
            energy += 1200000
            timestamp += 15.minutes
          end
          5.times do |i|
            Fabricate(:reading,
                      source: [Reading::Continuous::SLP, Reading::Continuous::SEP_BHKW][i % 2],
                      timestamp: timestamp,
                      energy_milliwatt_hour: energy,
                      power_milliwatt: 930000 + i,
                      reason: Reading::Continuous::REGULAR_READING,
                      quality: Reading::Continuous::READ_OUT,
                      meter_serialnumber: '12346578'
                     )
            energy += 1200000
            timestamp += 1.hour
          end
          5.times do |i|
            Fabricate(:reading,
                      source: [Reading::Continuous::SLP, Reading::Continuous::SEP_BHKW][i % 2],
                      timestamp: timestamp,
                      energy_milliwatt_hour: energy,
                      power_milliwatt: 930000 + i,
                      reason: Reading::Continuous::REGULAR_READING,
                      quality: Reading::Continuous::READ_OUT,
                      meter_serialnumber: '12346578'
                     )
            energy += 1200000
            timestamp += 1.day
          end
          5.times do |i|
            Fabricate(:reading,
                      source: [Reading::Continuous::SLP, Reading::Continuous::SEP_BHKW][i % 2],
                      timestamp: timestamp,
                      energy_milliwatt_hour: energy,
                      power_milliwatt: 930000 + i,
                      reason: Reading::Continuous::REGULAR_READING,
                      quality: Reading::Continuous::READ_OUT,
                      meter_serialnumber: '12346578'
                     )
            energy += 1200000
            timestamp += 1.month
          end
        end

        let(:slp_hour_json) do
          {
            "units"=>"milliwatt",
            "resource_id"=> slp_register.id,
            "in"=>[{"timestamp"=>1454288400.0, "value"=>930004.0},
                   {"timestamp"=>1454290200.0, "value"=>930006.0}],
            "out"=>[]
          }
        end
        let(:sep_day_json) do
          {
            "units"=>"milliwatt",
            "resource_id"=> sep_register.id,
            "out"=>[{"timestamp"=>1454285700.0, "value"=>930001.0},
                    {"timestamp"=>1454287500.0, "value"=>930003.0},
                    {"timestamp"=>1454289300.0, "value"=>930005.0}],
            "in"=>[]
          }
        end
        let(:slp_yesterday_json) do
          {
            "units"=>"milliwatt",
            "resource_id"=> slp_register.id,
            "in"=>[{"timestamp"=>1454284800.0, "value"=>930000.0},
                   {"timestamp"=>1454286600.0, "value"=>930002.0},
                   {"timestamp"=>1454288400.0, "value"=>930004.0},
                   {"timestamp"=>1454290200.0, "value"=>930006.0},
                   {"timestamp"=>1454292000.0, "value"=>930008.0},
                   {"timestamp"=>1454293800.0, "value"=>930010.0},
                   {"timestamp"=>1454295600.0, "value"=>930012.0},
                   {"timestamp"=>1454297400.0, "value"=>930014.0},
                   {"timestamp"=>1454299200.0, "value"=>930016.0},
                   {"timestamp"=>1454301000.0, "value"=>930018.0},
                   {"timestamp"=>1454302800.0, "value"=>930020.0},
                   {"timestamp"=>1454304600.0, "value"=>930022.0},
                   {"timestamp"=>1454306400.0, "value"=>930024.0},
                   {"timestamp"=>1454308200.0, "value"=>930026.0},
                   {"timestamp"=>1454310000.0, "value"=>930028.0},
                   {"timestamp"=>1454311800.0, "value"=>930030.0},
                   {"timestamp"=>1454313600.0, "value"=>930032.0},
                   {"timestamp"=>1454315400.0, "value"=>930034.0},
                   {"timestamp"=>1454317200.0, "value"=>930036.0},
                   {"timestamp"=>1454319000.0, "value"=>930038.0},
                   {"timestamp"=>1454320800.0, "value"=>930000.0},
                   {"timestamp"=>1454328000.0, "value"=>930002.0},
                   {"timestamp"=>1454335200.0, "value"=>930004.0},
                   {"timestamp"=>1454338800.0, "value"=>930000.0}],
            "out"=>[]
          }
        end
        let(:sep_month_json) do
          {
            "units"=>"milliwatt_hour",
            "resource_id"=> sep_register.id,
            "out"=>[{"timestamp"=>1454285700.0, "value"=>4800000.0}],
            "in"=>[]
          }
        end
        let(:slp_year_json) do
          {
            "units"=>"milliwatt_hour",
            "resource_id"=> slp_register.id,
            "in"=>[{"timestamp"=>1454284800.0, "value"=>7200000.0}],
            "out"=>[]
          }
        end

        it '200 standard profile' do
          Reading::Continuous.all.delete_all
          setup_readings
          time = Time.find_zone('UTC').local(2016, 2, 1, 1, 30, 1)
          begin
            Timecop.freeze(time)

            GET "/test/#{group.id}/registers/#{slp_register.id}/charts", $admin, duration: :hour

            expect(response).to have_http_status(200)
            expect(json).to eq(slp_hour_json)
            expect(response.headers['Cache-Control']).to eq "private, max-age=15"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil

            GET  "/test/#{group.id}/registers/#{sep_register.id}/charts", $admin, duration: :day

            expect(response).to have_http_status(200)
            expect(json).to eq(sep_day_json)
            expect(response.headers['Cache-Control']).to eq "private, max-age=900"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil

            GET  "/test/#{group.id}/registers/#{slp_register.id}/charts", $admin, duration: :day, timestamp: time - 1.day

            expect(response).to have_http_status(200)
            expect(json).to eq(slp_yesterday_json)
            expect(response.headers['Cache-Control']).to eq "private, max-age=86400"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil

            GET  "/test/#{group.id}/registers/#{sep_register.id}/charts", $admin, duration: :month

            expect(response).to have_http_status(200)
            expect(json).to eq(sep_month_json)
            expect(response.headers['Cache-Control']).to eq "private, max-age=3600"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil

            GET  "/test/#{group.id}/registers/#{slp_register.id}/charts", $admin, duration: :year

            expect(json).to eq(slp_year_json)
            expect(response).to have_http_status(200)
            expect(response.headers['Cache-Control']).to eq "private, max-age=86400"
            expect(response.headers['ETag']).not_to be_nil
            expect(response.headers['Last-Modified']).not_to be_nil
          ensure
            Timecop.return
          end
        end

        xit '200 virtual' do
        end
      end
    end
  end
end
