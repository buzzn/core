class Amperix

  # how to use
  # # wogeno oberländerstr bhkw
  # Amperix.new('721bcb386c8a4dab2510d40a93a7bf66', '0b81f58c19135bc01420aa0120ae7693').meters
  # Amperix.new('721bcb386c8a4dab2510d40a93a7bf66', '0b81f58c19135bc01420aa0120ae7693').get_day(unixtime)
  #

  # amperix  = Amperix.new('721bcb386c8a4dab2510d40a93a7bf66', '0b81f58c19135bc01420aa0120ae7693')
  # unixtime = Time.now.to_i
  # request  = amperix.get_day(unixtime)

# sensor_id replaces username and x_token the password
  def initialize(sensor_id, x_token)
    #sensor_id = "721bcb386c8a4dab2510d40a93a7bf66" #to be removed
    #x_token   = "0b81f58c19135bc01420aa0120ae7693" #dito
    @conn = Faraday.new(:url => 'https://api.mysmartgrid.de:8443/sensor/'+ sensor_id, ssl: {verify: false}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter :net_http
      faraday.headers["X-Token"] = x_token
      faraday.headers["X-Version"] = "1.0"
    end
  end

# This subroutine returns an array of time and work of the requested month on a time-grid of quarter hours
# This holds for data not older than one month only.
# Amperix thins out data older then one month (one value every quarter hour to one value every hour)
# and even more after two month (hour to day).
# This results in bad day-charts for historic data older then two month
  def get_day(time)
    datetime_start = Time.at(time.to_i/1000).in_time_zone.beginning_of_day.to_time.to_i
    datetime_end   = Time.at(time.to_i/1000).in_time_zone.end_of_day.to_time.to_i
    response = @conn.get do |req|
      req.url '?start='+(datetime_start-20).to_s+'&end='+datetime_end.to_s+'&resolution=15min&unit=watt'
#      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=day&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end

# This subroutine returns an array of time and work of the requested month on a time-grid of days
# This holds for data not older than one month only. Amperix thins out data older then one month and even more after two month.
def get_month(time)
    datetime_start = Time.at(time.to_i/1000).in_time_zone.beginning_of_month.to_time.to_i
    datetime_end   = Time.at(time.to_i/1000).in_time_zone.end_of_month.to_time.to_i
    puts datetime_end
    puts datetime_start
    response = @conn.get do |req|
      req.url '?start='+datetime_start.to_s+'&end='+datetime_end.to_s+'&resolution=day&unit=kwhperyear'
#      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=month&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end

# This subroutine returns an array of time and power of the requested hour on a time-grid of minutes
# Maximum delay is 5 minutes.
# This holds for data not older than one month only. amperix thins out data older then one month and even more after two month.
#
def get_hour(time)
    datetime_start = Time.at(time.to_i/1000).in_time_zone.beginning_of_hour.to_time.to_i
    datetime_end   = Time.at(time.to_i/1000).in_time_zone.end_of_hour.to_time.to_i
    #puts datetime_end
    #puts datetime_start
    #puts "HOUR"
    response = @conn.get do |req|
      req.url '?start='+(datetime_start-40).to_s+'&end='+datetime_end.to_s+'&resolution=minute&unit=watt'
#      req.url 'sensor/721bcb386c8a4dab2510d40a93a7bf66?interval=hour&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    return JSON.parse(response.body)
  end

# "real time view" with 5 minutes delay!
#
# This subroutine returns values of the last 340 seconds. Actually amperix data are updated every 5 minutes
# They are on a timegrid of 1 minute distance.
# Taking the first value of the return lead therefore to a value change every minute and you always
# have a delay of 5 minutes in "real time view"
def get_live
    datetime_start = Time.now.to_i - 300
    datetime_end   = Time.now.to_i
    # puts datetime_end
    # puts datetime_start
    response = @conn.get do |req|
      req.url '?start='+(datetime_start-40).to_s+'&end='+datetime_end.to_s+'&resolution=minute&unit=watt'
      req.headers["Accept"] = "application/json"
    end
    if response['content-length'] != "0"
      puts response.body
      return JSON.parse(response.body)
    else
      puts "NO DATA FROM AMPERIX API"
    end
  end

# sensor_id replaces username and x_token the password
  def initialize(sensor_id, x_token)
    #sensor_id = "721bcb386c8a4dab2510d40a93a7bf66" #to be removed
    #x_token   = "0b81f58c19135bc01420aa0120ae7693" #dito
    @conn = Faraday.new(:url => 'https://api.mysmartgrid.de:8443/sensor/'+ sensor_id, ssl: {verify: false}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter :net_http
      faraday.headers["X-Token"] = x_token
      faraday.headers["X-Version"] = "1.0"
    end
  end


  def meters
    response = @conn.get do |req|

    end
    return JSON.parse(response.body)
  end
end