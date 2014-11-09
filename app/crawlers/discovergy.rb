class Discovergy

  # how to use
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').meters
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').live(60009269)
  # Discovergy.new('info@philipp-osswald.de', 'Null8fünfzehn').raw(60009269)




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


  def raw( meter_uid,
           datetime_from = DateTime.now.beginning_of_minute.to_i * 1000,
           datetime_to   = DateTime.now.end_of_minute.to_i * 1000 )
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





end