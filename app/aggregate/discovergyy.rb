# coding: utf-8
class Discovergyy

  TIMEOUT = 5 # seconds

  # how to use
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').meters
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').get_live(60009269)
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').raw_with_power(60009269)


  # Discovergy.new('karin.smith@solfux.de', '19200buzzn').raw_with_power(60051431)

  # Discovergy.new('team@localpool.de', 'Zebulon_4711').raw_with_power(60139082)



  # discovergy  = Discovergy.new('team@localpool.de', 'Zebulon_4711')
  # date        = Time.current
  # start       = date.beginning_of_hour
  # ending      = start + 1.minute
  # request     = discovergy.raw('60009316', start.to_i*1000, ending.to_i*1000)




  def initialize(username, password)
    @username  = username
    @password  = password

    @conn = Faraday.new(:url => 'https://my.discovergy.com', ssl: {verify: false}, request: { timeout: TIMEOUT, open_timeout: TIMEOUT }) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, Rails.logger if Rails.env == 'development'
      faraday.adapter :net_http
    end
  end

  def parse(response)
    if response.status < 300
      MultiJson.load(response.body)
    else
      { 'status' => 'error',
        'reason' => "discovergy http status #{response.status}: #{response.body}" }
    end
  end

  def meters
    response = @conn.get do |req|
      req.url '/json/Api.getMeters'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
    end
    parse response
  end



  def get_live( meter_uid, num_of_seconds=6 )
    response = @conn.get do |req|
      req.url '/json/Api.getLive'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['numOfSeconds']  = num_of_seconds
    end
    parse response
  end

  def get_live_each( virtual_meter_uid )
    response = @conn.get do |req|
      req.url '/json/Api.getLastEach'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      req.params['meterId']       = "VIRTUAL_#{virtual_meter_uid}"
    end
    return MultiJson.load(response.body)
  end

  def get_day( meter_uid, timestamp)
    datetime = Time.at(timestamp.to_i/1000).in_time_zone
    response = @conn.get do |req|
      req.url '/json/Api.getDayEveryFifteenMinutes'
      #req.url '/json/Api.getDay'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['day']           = datetime.day
      req.params['month']         = datetime.month
      req.params['year']          = datetime.year
    end
    parse response
  end

  def get_month( meter_uid, timestamp)
    datetime_start = Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_month
    datetime_end = Time.at(timestamp.to_i/1000).in_time_zone.end_of_month
    response = @conn.get do |req|
      req.url '/json/Api.getDataEveryDay'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['fromDay']       = datetime_start.day
      req.params['fromMonth']     = datetime_start.month
      req.params['fromYear']      = datetime_start.year
      req.params['toDay']         = 2 #datetime_end.day
      req.params['toMonth']       = datetime_end.month+1
      req.params['toYear']        = datetime_end.year
    end
    parse response
  end

  def get_year( meter_uid, timestamp)
    datetime_start = Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_year
    datetime_end = Time.at(timestamp.to_i/1000).in_time_zone.end_of_year + 1.second
    response = @conn.get do |req|
      req.url '/json/Api.getDataEveryDay'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['fromDay']       = datetime_start.day
      req.params['fromMonth']     = datetime_start.month
      req.params['fromYear']      = datetime_start.year
      req.params['toDay']         = 2 #datetime_end.day
      req.params['toMonth']       = datetime_end.month
      req.params['toYear']        = datetime_end.year
    end
    parse response
  end

  def get_hour( meter_uid, timestamp )
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_hour).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).in_time_zone.end_of_hour).to_i*1000
    response = @conn.get do |req|
      req.url '/json/Api.getRawWithPower'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['from']          = datetime_from
      req.params['to']            = datetime_to
    end
    parse response
  end


  def raw( meter_uid,
           datetime_from = (Time.current.utc- 1.minute).to_i * 1000,
           datetime_to   = Time.current.utc.to_i * 1000 )
    @datetime_from  = datetime_from
    @datetime_to    = datetime_to
    response = @conn.get do |req|
      req.url '/json/Api.getRaw'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['from']          = @datetime_from
      req.params['to']            = @datetime_to
    end
    parse response
  end



  def raw_with_power(  meter_uid,
                       datetime_from = (Time.current.utc- 1.minute).to_i * 1000,
                       datetime_to   = Time.current.utc.to_i * 1000 )
    @datetime_from  = datetime_from
    @datetime_to    = datetime_to
    response = @conn.get do |req|
      req.url '/json/Api.getRawWithPower'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      #TODO: make this dynamic
      if meter_uid == '9999997'
        req.params['meterId']       = "VIRTUAL_#{meter_uid}"
      else
        req.params['meterId']       = "EASYMETER_#{meter_uid}"
      end
      req.params['from']          = @datetime_from
      req.params['to']            = @datetime_to
    end
    parse response
  end


end
