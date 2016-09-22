# coding: utf-8
class DiscovergyOauth1

  TIMEOUT = 5 # seconds

  #consumer key + secret are specific for the buzzn app, so they have to be only registered once and don't change
  @consumer_key = nil
  @consumer_secret = nil

  # how to use
  # discovergy = DiscovergyOauth1.new('test@email.de', 'testpassword')
  # discovergy.meters

  ###################
  #### IMPORTANT ####
  ###################
  # this is only for testing the connectivity.
  # the real oauth1 flow will be implemented later.
  # we will also implement using the API with already existing access_token.
  # but first must the discovergy API go online.



  def initialize(email, password)
    @email  = email
    @password  = password

    #TODO: change url to https://api.discovergy.com
    @conn = Faraday.new(:url => 'http://localhost:9006', ssl: {verify: false}, request: { timeout: TIMEOUT, open_timeout: TIMEOUT }) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, Rails.logger if Rails.env == 'development'
      faraday.adapter :net_http
    end

    if !@consumer_secret && !@consumer_key
      @consumer_token = register_application
      @consumer_key = @consumer_token['key']
      @consumer_secret = @consumer_token['secret']
    end

    #TODO: change site to https://api.discovergy.com
    @consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, :site => 'http://localhost:9006', :request_token_path => '/public/v1/oauth1/request_token', :authorize_path => '/public/v1/oauth1/authorize', :access_token_path => '/public/v1/oauth1/access_token')

    @request_token = @consumer.get_request_token
    @verifier = authorize
    @access_token = @request_token.get_access_token(:oauth_verifier => @verifier)
  end

  def register_application
    response = @conn.post do |req|
      req.url '/public/v1/oauth1/consumer_token'
      req.headers['Content-Type'] = "application/x-www-form-urlencoded"
      req.params['client'] = 'buzzn'
    end
    return MultiJson.load(response.body)
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
    return @access_token.response.body
  end


end
