require 'buzzn/discovergy/throughput'

module Buzzn::Discovergy
  class Facade

    TIMEOUT = 5 # seconds

    def initialize(url, max_concurrent)
      @url   = url
      @max_concurrent = max_concurrent
      @throughput = Buzzn::Discovergy::Throughput.new
      @consumer

      # maybe put the url into the constructor?
      @conn = Faraday.new(:url => 'https://api.discovergy.com', ssl: {verify: false}, request: {timeout: TIMEOUT, open_timeout: TIMEOUT}) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger, Rails.logger if Rails.env == 'development'
        faraday.adapter :net_http
      end
    end

    # def virtual_meter(broker, interval)
    #   # TODO
    # end

    # def aggregated_virtual_meter(broker, interval)
    #   # TODO
    # end

    # def easy_meter(broker, meter, interval)
    #   # TODO
    # end

    # input params:
    #  broker: class with information about credentials and requested meterID
    #  interval: class with information about the beginning and end date
    #  collection: boolean that indicates whether to request data preaggregated or as a collection
    def readings(broker, interval, collection=false)

    end

    def create_virtual_meter(group, mode)
      # TODO
    end

    def auth_process(email, password)
      request_token = get_request_token
      verifier = authorize(request_token, email, password)
      access_token = get_access_token(request_token, verifier, email, password)
    end

    def register_application
      response = @conn.post do |req|
        req.url '/public/v1/oauth1/consumer_token'
        req.headers['Content-Type'] = "application/x-www-form-urlencoded"
        req.params['client'] = "buzzn app #{Rails.env}"
      end
      if !response.success?
        raise CrawlerError.new('unable to register at discovergy')
      end
      json_response = MultiJson.load(response.body)
      consumer_key = json_response['key']
      consumer_secret = json_response['secret']
      # maybe use the url from the constructor?
      if consumer_key.nil? || consumer_secret.nil?
        raise CrawlerError.new('unable to parse data from discovergy')
      end
      @consumer = OAuth::Consumer.new(
        consumer_key,
        consumer_secret,
        :site => 'https://api.discovergy.com',
        :request_token_path => '/public/v1/oauth1/request_token',
        :authorize_path => '/public/v1/oauth1/authorize',
        :access_token_path => '/public/v1/oauth1/access_token'
      )
    end

    def get_request_token
      if !@consumer
        register_application
      end
      request_token = @consumer.get_request_token
      if !request_token
        raise CrawlerError.new('unable to get refresh token from discovergy')
      end
      return request_token
    end

    def authorize(request_token, email, password)
      if !request_token
        request_token = get_request_token
      end
      response = @conn.get do |req|
        req.url '/public/v1/oauth1/authorize'
        req.headers['Content-Type'] = 'text/plain'
        req.params['oauth_token'] = request_token.token
        req.params['email'] = email
        req.params['password'] = password
      end
      puts response.body
      if !response.success?
        raise CrawlerError.new('authorization failed at discovergy')
      end
      return response.body.split('=')[1]
    end

    def get_access_token(request_token, verifier, email, password)
      if !request_token
        request_token = get_request_token
      end
      if !verifier
        verifier = authorize(request_token, email, password)
      end
      access_token = request_token.get_access_token(:oauth_verifier => verifier)
      if !access_token
        raise CrawlerError.new('unable to get access token from discovergy')
      end
      return access_token
      # TODO: save access token in DB for future use
      #contract.update_column(:encrypted_external_access_token, Contract.encrypt_external_access_token(access_token.token, key: Rails.application.secrets.attr_encrypted_key))
      #contract.update_column(:encrypted_external_access_token_secret, Contract.encrypt_external_access_token_secret(access_token.secret, key: Rails.application.secrets.attr_encrypted_key))
    end

    def read_consumer

    end

    [:register_application, :get_request_token, :authorize, :get_access_token, :readings,
      :create_virtual_meter].each do |method|

      alias :"do_#{method}" :"#{method}"

      define_method method do |*args|
        before
        begin
          send(:"do_#{method}", *args)
        ensure
          after
        end
      end

      # TODO: commented out only for testing!!!!!
      #private method
    end

    private

    def before
      ActiveRecord::Base.clear_active_connections!
      @throughput.increment
      if @throughput.current > @max_concurrent
        raise CrawlerError.new('discovergy limit reached')
      end
    end

    def after
      @throughput.decrement
    end

  end
end
