# coding: utf-8
class DiscovergyOauth1

  TIMEOUT = 5 # seconds

  # how to use
  # discovergy = DiscovergyOauth1.new('test@email.de', 'testpassword')
  # discovergy.meters

  ###################
  #### IMPORTANT ####
  ###################
  # this is only for testing the connectivity.
  # the real oauth1 flow will be implemented later.
  # we will also implement using the API with already existing access_token.



  def initialize(contract)
    # consumer key + secret are specific for the buzzn app, so they have to be only registered once and don't change
    @consumer_key = 'ugv3tngmrah0e6ph41v78ohq4j'
    @consumer_secret = 'locutd1nfv43ip4804mkkhd5me'

    @email  = contract.username
    @password  = contract.password

    @conn = Faraday.new(:url => 'https://api.discovergy.com', ssl: {verify: false}, request: { timeout: TIMEOUT, open_timeout: TIMEOUT }) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, Rails.logger if Rails.env == 'development'
      faraday.adapter :net_http
    end

    consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, :site => 'https://api.discovergy.com', :request_token_path => '/public/v1/oauth1/request_token', :authorize_path => '/public/v1/oauth1/authorize', :access_token_path => '/public/v1/oauth1/access_token')

    if contract.external_access_token && contract.external_access_token_secret
      hash = {
        :oauth_token          => contract.external_access_token,
        "oauth_token"         => contract.external_access_token,
        :oauth_token_secret   => contract.external_access_token_secret,
        "oauth_token_secret"  => contract.external_access_token_secret
      }
      @access_token = OAuth::AccessToken.from_hash(consumer, hash)
    else
      @request_token = consumer.get_request_token
      verifier = authorize.split('=')[1] #TODO: catch problems verifying the user credentials
      @access_token = @request_token.get_access_token(:oauth_verifier => verifier)
      contract.update_column(:external_access_token, @access_token.token)
      contract.update_column(:external_access_token_secret, @access_token.secret)
    end
  end

  def register_application
    response = @conn.post do |req|
      req.url '/public/v1/oauth1/consumer_token'
      req.headers['Content-Type'] = "application/x-www-form-urlencoded"
      req.params['client'] = 'buzzn app'
    end
    consumer_token = response.body
    @consumer_key = consumer_token['key']
    @consumer_secret = consumer_token['secret']
  end

  def authorize
    response = @conn.get do |req|
      req.url '/public/v1/oauth1/authorize'
      req.headers['Content-Type'] = "text/plain"
      req.params['oauth_token'] = @request_token.token
      req.params['email'] = @email
      req.params['password'] = @password
    end
    return response.body
  end




  def meters
    @access_token.get('/public/v1/meters')
    return @access_token.response
  end




  def live(meter_id)
    @access_token.get('/public/v1/readings?meterId=EASYMETER_' + meter_id + '&from=' + ((Time.now - 5.seconds).to_i*1000).to_s)
    return @access_token.response
  end

  def hour(meter_id, timestamp)
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_hour).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).in_time_zone.end_of_hour).to_i*1000
    @access_token.get('/public/v1/readings?meterId=EASYMETER_' + meter_id + '&from=' + datetime_from.to_s + '&to=' + datetime_to.to_s + '&resolution=raw&fields=power')
    return @access_token.response
  end

  def day(meter_id, timestamp)
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_day).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).in_time_zone.end_of_day).to_i*1000
    @access_token.get('/public/v1/readings?meterId=EASYMETER_' + meter_id + '&from=' + datetime_from.to_s + '&to=' + datetime_to.to_s + '&resolution=fifteen_minutes&fields=power')
    return @access_token.response
  end

  def month(meter_id, timestamp)
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_month).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).in_time_zone.end_of_month).to_i*1000
    @access_token.get('/public/v1/readings?meterId=EASYMETER_' + meter_id + '&from=' + datetime_from.to_s + '&to=' + datetime_to.to_s + '&resolution=one_day&fields=energy,energyOut')
    return @access_token.response
  end

  def year(meter_id, timestamp)
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_year).to_i*1000
    datetime_to    = (Time.at(timestamp.to_i/1000).in_time_zone.end_of_year).to_i*1000
    @access_token.get('/public/v1/readings?meterId=EASYMETER_' + meter_id + '&from=' + datetime_from.to_s + '&to=' + datetime_to.to_s + '&resolution=one_month&fields=energy,energyOut')
    return @access_token.response
  end

  def reading(meter_id, timestamp)
    datetime_from  = (Time.at(timestamp.to_i/1000).in_time_zone).to_i*1000
    datetime_to  = datetime_from + 2000
    @access_token.get('/public/v1/readings?meterId=EASYMETER_' + meter_id + '&from=' + datetime_from.to_s + '&to=' + datetime_to.to_s + '&resolution=raw')
    return @access_token.response
  end


end
