class Discovergy

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




  def initialize(username, password)
    @username  = username
    @password  = password

    @conn = Faraday.new(:url => 'https://my.discovergy.com', ssl: {verify: false}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter :net_http
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
    datetime = Time.at(timestamp.to_i/1000)
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
    datetime_start = Time.at(timestamp.to_i/1000).beginning_of_month
    datetime_end = Time.at(timestamp.to_i/1000).end_of_month
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
    datetime_from  = (Time.at(timestamp.to_i/1000).beginning_of_hour).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).end_of_hour).to_i*1000
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