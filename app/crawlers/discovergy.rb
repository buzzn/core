class Discovergy

  # test
  # api = Discovergy.new('stefan@buzzn.net', '19200buzzn', 'EASYMETER_1024000034')
  # api.call(1394288813000, 1394288816000)

  def initialize(username, password, meter_uid)
    @username  = username
    @password  = password
    @meter_uid = meter_uid

    @conn = Faraday.new(:url => 'https://my.discovergy.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      #faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def call(datetime_from, datetime_to)
    response = @conn.get do |req|
      req.url '/json/Api.getRaw'
      req.headers['Content-Type'] = 'application/json'
      req.params['user'] = @username
      req.params['password'] = @password
      req.params['meterId'] = @meter_uid
      req.params['from'] = datetime_from
      req.params['to'] = datetime_to
    end
    return JSON.parse(response.body)
  end

end