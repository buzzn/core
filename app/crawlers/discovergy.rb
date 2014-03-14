require "net/https"
require "uri"

class Discovergy

  def initialize(meter_uid, username, password, datetime)
    @meter_uid = meter_uid
    @username  = user
    @password  = password
    @datetime  = datetime
  end

  def readings_for_all_meters(date)

    params = URI.encode_www_form([
      ['user', @username],
      ['password', @password],
      ['day', @datetime.day],
      ['month', @datetime.month],
      ['year', @datetime.year]
      ])

    uri               = URI.join("https://my.discovergy.com/json/Api.getReadingsForAllMeters", params)
    http              = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
    request           = Net::HTTP::Get.new(uri.request_uri)
    response          = http.request(request)

    return response.body
  end


end