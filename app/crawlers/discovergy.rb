class Discovergy

  # how to use
  # Discovergy.new('stefan@buzzn.net', '19200buzzn', 'EASYMETER_1024000034').call
  # Discovergy.new('karin.smith@solfux.de', '19200buzzn', 'EASYMETER_60051431').call
  # Discovergy.new('justus@buzzn.net', 'PPf93TcR', 'EASYMETER_1124001747').call



  def initialize(username, password, meter_uid)
    @username  = username
    @password  = password
    @meter_uid = meter_uid

    @conn = Faraday.new(:url => 'https://my.discovergy.com', ssl: {verify: false}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter :net_http
    end
  end

  def call( datetime_from = DateTime.now.beginning_of_minute.to_i * 1000,
            datetime_to   = DateTime.now.end_of_minute.to_i * 1000 )

    @datetime_from  = datetime_from
    @datetime_to    = datetime_to

    response = @conn.get do |req|
      req.url '/json/Api.getRaw'
      req.headers['Content-Type'] = 'application/json'
      req.params['user']          = @username
      req.params['password']      = @password
      req.params['meterId']       = @meter_uid
      req.params['from']          = @datetime_from
      req.params['to']            = @datetime_to
    end
    return JSON.parse(response.body)
  end

end