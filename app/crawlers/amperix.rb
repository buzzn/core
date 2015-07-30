class Amperix

  # how to use
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').meters
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').live(60009269)
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').raw_with_power(60009269)


  # Discovergy.new('karin.smith@solfux.de', '19200buzzn').raw_with_power(60051431)

  # Discovergy.new('team@buzzn-metering.de', 'Zebulon_4711').raw_with_power(60139082)



  # discovergy  = Discovergy.new('team@buzzn-metering.de', 'Zebulon_4711')
  # date        = Time.now.in_time_zone
  # start       = date.beginning_of_hour
  # ending      = start + 1.minute
  # request     = discovergy.raw('60009316', start.to_i*1000, ending.to_i*1000)

#PHP/CURL:
# TTs: $url = "https://api.mysmartgrid.de:8443/sensor/17c2590a4145aa882a77bc4a741c5145?interval=hour&unit=watt";
#  $headers = array(
#    'Accept: application/json',
#    'X-Version: 1.0',
#    'X-Token: 11489501d8c5124f33c19c4079241a35',
#  );

# $url = "https://api.mysmartgrid.de:8443/sensor/9a0b26706da4e4d7ab182e2e1ec3f9b1?interval=hour&unit=watt";
#  $headers = array(
#    'Accept: application/json',
#    'X-Version: 1.0',
#    'X-Token: 6490bf61d81851dd21dae73acc895354',
# $url = "https://api.flukso.net/sensor/af7b84287f0839f99f5f6503cffd3ce2?interval=hour&unit=watt";
#  $headers = array(
#    'Accept: application/json',
#    'X-Version: 1.0',
#    'X-Token: b0e1ddcf7f8177432571490b4f6a345b',
#  );
# $ch = curl_init($url);

#  curl_setopt($ch, CURLOPT_URL, $url);
#  curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
#  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
#  curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
#  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
#  $output = curl_exec($ch);

# curl https://my.discovergy.com/json/Api.getRawWithPower?meterId=EASYMETER_60009269&from=1423609200000&to=1423609222000&password=Null8f%C3%BCnfzehn&user=info%40philipp-osswald.de
# liefert schon die werte!
#
#manuell (BHKW Oberländer 20):
#[4] pry(main)> c = Curl::Easy.new("https://api.mysmartgrid.de:8443/sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=hour&unit=watt") do |curl|
#[4] pry(main)*   curl.headers["X-Token"] = "0b81f58c19135bc01420aa0120ae7693"
#[4] pry(main)*   curl.verbose = true
#[4] pry(main)*   curl.headers["Accept"] = "application/json"
#[4] pry(main)*   curl.ssl_verify_peer =false
#[4] pry(main)*   curl.headers["X-Version"] = "1.0"
#[4] pry(main)* end
#=> #<Curl::Easy https://api.mysmartgrid.de:8443/sensor/721bcb386c8>
#[5] pry(main)> c.perform
#* Hostname was NOT found in DNS cache
#*   Trying 5.9.53.130...
#* Connected to api.mysmartgrid.de (5.9.53.130) port 8443 (#1)
#* successfully set certificate verify locations:
#*   CAfile: none
#  CApath: /etc/ssl/certs
#* SSL connection using ECDHE-RSA-AES256-GCM-SHA384
#* Server certificate:
#*    subject: C=DE; O=Fraunhofer-Gesellschaft; OU=ITWM; CN=api.mysmartgrid.de
#*    start date: 2013-05-13 09:13:45 GMT
#*    expire date: 2023-05-11 09:13:45 GMT
#*    common name: api.mysmartgrid.de (matched)
#*    issuer: C=DE; O=Fraunhofer-Gesellschaft; OU=ITWM; CN=mySmartGrid CA; emailAddress=team@mysmartgrid.de
#*    SSL certificate verify result: self signed certificate in certificate chain (19), continuing anyway.
#> GET /sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=hour&unit=watt HTTP/1.1
#Host: api.mysmartgrid.de:8443
#X-Token: 0b81f58c19135bc01420aa0120ae7693
#Accept: application/json
#X-Version: 1.0
#
#< HTTP/1.1 200 OK
#* Server nginx is not blacklisted
#< Server: nginx
#< Date: Tue, 21 Jul 2015 09:40:31 GMT
#< Content-Type: application/json
#< Content-Length: 1573
#< Connection: keep-alive
#< Vary: Accept-Encoding
#<
#* Connection #1 to host api.mysmartgrid.de left intact
#=> true
#[6] pry(main)> puts c.body_str
#[[1437468060,380.000000016],[1437468120,393.333333336],[1437468180,386.66666667600003],[1437468240,393.333333336],[1437468300,393.333333336],[1437468360,381.333333348],[1437468420,378.666666684],[1437468480,377.333333316],[1437468540,389.33333334],[1437468600,393.333333336],[1437468660,393.333333336],[1437468720,386.66666667600003],[1437468780,386.66666667600003],[1437468840,378.666666684],[1437468900,378.0],[1437468960,389.999999988],[1437469020,389.999999988],[1437469080,389.999999988],[1437469140,393.333333336],[1437469200,386.66666667600003],[1437469260,378.0],[1437469320,378.0],[1437469380,384.000000012],[1437469440,393.333333336],[1437469500,392.666666652],[1437469560,387.33333332399997],[1437469620,392.666666652],[1437469680,378.0],[1437469740,378.0],[1437469800,391.33333332],[1437469860,393.333333336],[1437469920,386.66666667600003],[1437469980,393.333333336],[1437470040,391.33333332],[1437470100,378.0],[1437470160,378.0],[1437470220,378.0],[1437470280,388.000000008],[1437470340,393.333333336],[1437470400,388.666666656],[1437470460,391.33333332],[1437470520,388.666666656],[1437470580,378.0],[1437470640,378.0],[1437470700,381.99999999600004],[1437470760,393.333333336],[1437470820,388.666666656],[1437470880,391.33333332],[1437470940,393.333333336],[1437471000,373.33333331999995],[1437471060,380.000000016],[1437471120,380.000000016],[1437471180,393.333333336],[1437471240,393.333333336],[1437471300,386.66666667600003],[1437471360,393.333333336],[1437471420,"-nan"],[1437471480,"-nan"],[1437471540,"-nan"],[1437471600,"-nan"],[1437471660,"-nan"]]
#=> nil

  def mySmartGridOberlCurl(time)
    c = Curl::Easy.new("https://api.mysmartgrid.de:8443/sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=hour&unit=watt") do |curl|
      curl.headers["X-Token"] = "0b81f58c19135bc01420aa0120ae7693"
      curl.verbose = true
      curl.headers["Accept"] = "application/json"
      curl.ssl_verify_peer =false
      curl.headers["X-Version"] = "1.0"
    end
    c.perform
    puts c.body_str
    return JSON.parse(c.body_str)
  end

  def mySmartGridOberlFaraDay(serialnumber, time)
    datetime_start = Time.at(time.to_i/1000).in_time_zone.beginning_of_day.to_time.to_i
    datetime_end   = Time.at(time.to_i/1000).in_time_zone.end_of_day.to_time.to_i
    response = @conn.get do |req|
      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?start='+(datetime_start-70).to_s+'&end='+datetime_end.to_s+'&resolution=15min&unit=watt'
#      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=day&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end
  def mySmartGridOberlFaraLive(serialnumber, time)
    response = @conn.get do |req|
      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=minute&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end
  def mySmartGridOberlFaraMonth(serialnumber, time)
    datetime_start = Time.at(time.to_i/1000).in_time_zone.beginning_of_month.to_time.to_i
    datetime_end   = Time.at(time.to_i/1000).in_time_zone.end_of_month.to_time.to_i
    puts datetime_end
    puts datetime_start
    response = @conn.get do |req|
      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?start='+datetime_start.to_s+'&end='+datetime_end.to_s+'&resolution=day&unit=watt'
#      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=month&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end
def mySmartGridOberlFaraHour(serialnumber, time)
    datetime_start = Time.at(time.to_i/1000).in_time_zone.beginning_of_hour.to_time.to_i
    datetime_end   = Time.at(time.to_i/1000).in_time_zone.end_of_hour.to_time.to_i
    puts datetime_end
    puts datetime_start
    puts "HOUR"
    response = @conn.get do |req|
      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?start='+(datetime_start-40).to_s+'&end='+datetime_end.to_s+'&resolution=minute&unit=watt'
#      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=hour&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end


  def initialize(username, password)
    @username  = username
    @password  = password

    @conn = Faraday.new(:url => 'https://api.mysmartgrid.de:8443/', ssl: {verify: false}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter :net_http
      faraday.headers["X-Token"] = "0b81f58c19135bc01420aa0120ae7693"
#      faraday.verbose = true
#      faraday.ssl_verify_peer =false
      faraday.headers["X-Version"] = "1.0"
    end
  end


  def meters
    response = @conn.get do |req|
      req.url '/json/Api.getMeters'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
    end
    return JSON.parse(response.body)
  end



  def live( meter_uid, num_of_seconds=2 )
    response = @conn.get do |req|
      req.url '/json/Api.getLive'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = "EASYMETER_#{meter_uid}"
      req.params['numOfSeconds']  = num_of_seconds
    end
    return JSON.parse(response.body)
  end

  def getDay( meter_uid, timestamp)
    datetime = Time.at(timestamp.to_i/1000).in_time_zone
    puts '******'
    puts datetime.to_s
    puts datetime.day.to_s
    puts datetime.month.to_s
    puts '******'
    response = @conn.get do |req|
      req.url '/json/Api.getDay'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = "EASYMETER_#{meter_uid}"
      req.params['day']           = datetime.day
      req.params['month']         = datetime.month
      req.params['year']          = datetime.year
    end
    return JSON.parse(response.body)
  end

  def getDataEveryDay( meter_uid, timestamp)
    datetime_start = Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_month
    datetime_end = Time.at(timestamp.to_i/1000).in_time_zone.end_of_month
    response = @conn.get do |req|
      req.url '/json/Api.getDataEveryDay'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = "EASYMETER_#{meter_uid}"
      req.params['fromDay']       = datetime_start.day
      req.params['fromMonth']     = datetime_start.month
      req.params['fromYear']      = datetime_start.year
      req.params['toDay']         = datetime_end.day
      req.params['toMonth']       = datetime_end.month
      req.params['toYear']        = datetime_end.year
    end
    return JSON.parse(response.body)
  end

  def getHour( meter_uid, timestamp )
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_hour).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).in_time_zone.end_of_hour).to_i*1000
    response = @conn.get do |req|
      req.url '/json/Api.getRawWithPower'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = "EASYMETER_#{meter_uid}"
      req.params['from']          = datetime_from
      req.params['to']            = datetime_to
    end
    return JSON.parse(response.body)
  end


  def raw( meter_uid,
           datetime_from = (Time.now.in_time_zone.utc- 1.minute).to_i * 1000,
           datetime_to   = Time.now.in_time_zone.utc.to_i * 1000 )
    @datetime_from  = datetime_from
    @datetime_to    = datetime_to
    response = @conn.get do |req|
      req.url '/json/Api.getRaw'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = "EASYMETER_#{meter_uid}"
      req.params['from']          = @datetime_from
      req.params['to']            = @datetime_to
    end
    return JSON.parse(response.body)
  end



  def raw_with_power(  meter_uid,
                       datetime_from = (Time.now.in_time_zone.utc- 1.minute).to_i * 1000,
                       datetime_to   = Time.now.in_time_zone.utc.to_i * 1000 )
    @datetime_from  = datetime_from
    @datetime_to    = datetime_to
    response = @conn.get do |req|
      req.url '/json/Api.getRawWithPower'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = "EASYMETER_#{meter_uid}"
      req.params['from']          = @datetime_from
      req.params['to']            = @datetime_to
    end
    return JSON.parse(response.body)
  end


end