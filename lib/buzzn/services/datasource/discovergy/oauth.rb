require 'ostruct'

require_relative '../discovergy'

class Services::Datasource::Discovergy::Oauth

  include Import['config.discovergy_login',
                 'config.discovergy_password']

  TIMEOUT = 5 # seconds
  URL = 'https://api.discovergy.com/public/v1'

  attr_reader :path

  def initialize(**)
    super
    uri = URI.parse(URL)
    @path = uri.path
    @url = uri.to_s.sub(/#{uri.path}/, '')
    @logger = Buzzn::Logger.new(self)
    @_mutex = Mutex.new
  end

  def access_token_create
    @_mutex.synchronize do
      if @access_token
        token_hash = {
          # old code claims both are needed
          :oauth_token          => @access_token.token,
          "oauth_token"         => @access_token.token,
          :oauth_token_secret   => @access_token.secret,
          "oauth_token_secret"  => @access_token.secret
        }
        OAuth::AccessToken.from_hash(consumer, token_hash)
      else
        @access_token = request_access_token
      end
    end
  end

  def reset
    @_mutex.synchronize do
      @consumer = nil
      @access_token = nil
    end
  end

  private

  def consumer_token
    conn = Faraday.new(:url => @url, ssl: {verify: false}, request: {timeout: TIMEOUT, open_timeout: TIMEOUT}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, @logger
      faraday.adapter :net_http
    end
    response = conn.post do |req|
      req.url "#{@path}/oauth1/consumer_token"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.params['client'] = 'buzzn app'
    end
    if !response.success?
      reset
      raise Buzzn::DataSourceError.new('unable to register at discovergy')
    end
    json = MultiJson.load(response.body)
    if json['key'].nil? || json['secret'].nil?
      reset
      Buzzn::DataSourceError.new('unable to parse data from discovergy')
    end
    OpenStruct.new(json)
  end

  def consumer
    @consumer ||=
      begin
        token = consumer_token
        OAuth::Consumer.new(
          token.key,
          token.secret,
          site:               @url,
          request_token_path: "#{@path}/oauth1/request_token",
          authorize_path:     "#{@path}/oauth1/authorize",
          access_token_path:  "#{@path}/oauth1/access_token"
        )
      rescue OAuth::Unauthorized
        reset
        raise Buzzn::DataSourceError.new('unable to get refresh token from discovergy')
      end
  end

  def verifier(request_token)
    conn = Faraday.new(:url => @url, ssl: {verify: false}, request: {timeout: TIMEOUT, open_timeout: TIMEOUT}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, @logger
      faraday.adapter :net_http
    end
    response = conn.get do |req|
      req.url "#{@path}/oauth1/authorize"
      req.headers['Content-Type'] = 'text/plain'
      req.params['oauth_token']   = request_token.token
      req.params['email']         = discovergy_login
      req.params['password']      = discovergy_password
    end
    unless response.success?
      reset
      raise Buzzn::DataSourceError.new('authorization failed at discovergy: ' + response.body)
    end
    @logger.info(response.body)
    response.body.split('=')[1]
  end

  def request_access_token
    request_token = consumer.get_request_token
    request_token.get_access_token(:oauth_verifier => verifier(request_token))
  end
end