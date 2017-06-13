module Buzzn::Discovergy
  class Facade

    LOCK_KEY = 'discovergy.lock.key'
    SEP = '_:_'

    TIMEOUT = 5 # seconds

    def initialize(redis = Redis.current, url='https://api.discovergy.com', max_concurrent=30)
      @logger = Buzzn::Logger.new(self)
      @redis = redis
      @url   = url
      @max_concurrent = max_concurrent
      @throughput = Buzzn::Discovergy::Throughput.new(redis)
      @lock = RemoteLock.new(RemoteLock::Adapters::Redis.new(redis))
    end

    # This function sends the request to the discovergy API and returns the unparsed response
    # input params:
    #  broker: class with information about credentials and requested meterID
    #  interval: class with information about the beginning and end date
    #  mode: :in or :out to decide which data is requested for a meter
    #  collection: boolean that indicates whether to request data preaggregated or as a collection
    # returns:
    #  Net::HTTPResponse with requested data
    def readings(broker, interval, mode, collection=false, retried=false)
      return "[]" if collection && !broker.mode.include?(mode.to_s)
      @logger.debug{"#readings Broker[mode: #{broker.mode} external_id: #{broker.external_id} resource: #{broker.resource_type}:#{broker.resource_id}] #{interval} mode: #{mode} collection: #{collection}"}
      access_token = build_access_token_from_broker_or_new(broker)
      meter_id = broker.external_id

      if interval.nil?
        # for dummies: from a technical point a two way meter is counting
        # either 'in' or 'out' never both at the same time. the direction
        # will be the sign of the value: negative values are 'out' and
        # positive values are 'in'
        query = '/public/v1/last_reading?meterId=' + meter_id + '&fields=power&each=' + collection.to_s
      else
        energy_out = ""
        if mode == :out
          energy_out = "Out"
        end

        case interval.duration
        when :second
          query = '/public/v1/readings?meterId=' + meter_id + '&from=' + interval.from_as_millis.to_s + '&to=' +
            interval.to_as_millis.to_s + "&resolution=raw&fields=energy#{energy_out}"
        when :hour
          query = '/public/v1/readings?meterId=' + meter_id + '&from=' + interval.from_as_millis.to_s + '&to=' +
            interval.to_as_millis.to_s + '&resolution=raw&fields=power&each=' + collection.to_s
        when :day
          # discovergy does not deliver power data - datasource will calculate
          # the power from the given energy data
          query = '/public/v1/readings?meterId=' + meter_id + '&from=' + interval.from_as_millis.to_s + '&to=' +
            interval.to_as_millis.to_s + "&resolution=fifteen_minutes&fields=energy#{energy_out}&each=" + collection.to_s
        when :month
          query = '/public/v1/readings?meterId=' + meter_id + '&from=' + interval.from_as_millis.to_s + '&to=' +
            interval.to_as_millis.to_s + "&resolution=one_day&fields=energy#{energy_out}&each=" + collection.to_s
        when :year
          query = '/public/v1/readings?meterId=' + meter_id + '&from=' + interval.from_as_millis.to_s + '&to=' +
            interval.to_as_millis.to_s + "&resolution=one_month&fields=energy#{energy_out}&each=" + collection.to_s
        end
      end
      access_token.get(query)
      response = access_token.response

      case response.code.to_i
      when (200..299)
        return response.body
      when 401
        if !retried
          @logger.error {"retry authentication #{broker.inspect}: #{response.body}" }
          register_application
          access_token = build_access_token_from_broker_or_new(broker, true)
          response = self.readings(broker, interval, mode, collection, true)
          return response
        else
          @logger.error {"failed request (401 - unauthorized): #{query}"}
          raise Buzzn::DataSourceError.new('unauthorized to get data from discovergy: ' + response.body)
        end
      else
        raise Buzzn::DataSourceError.new('unable to get data from discovergy: ' + response.body)
      end
    end

    def single_reading(broker, timestamp, mode, retried=false)
      @logger.debug{"#single_reading Broker[mode: #{broker.mode} external_id: #{broker.external_id} resource: #{broker.resource_type}:#{broker.resource_id}] timestamp: #{timestamp} mode: #{mode}"}
      access_token = build_access_token_from_broker_or_new(broker)
      meter_id = broker.external_id
      energy_out = ""
      if mode == :out
        energy_out = "Out"
      end

      query = '/public/v1/readings?meterId=' + meter_id + '&from=' + timestamp.to_s + '&to=' + (timestamp + 2000).to_s + "&resolution=raw&fields=energy#{energy_out}"
      access_token.get(query)
      response = access_token.response

      case response.code.to_i
      when (200..299)
        return response.body
      when 401
        if !retried
          @logger.error("retry authentication #{broker.inspect}: " + response.body)
          register_application
          access_token = build_access_token_from_broker_or_new(broker, true)
          response = self.single_reading(broker, timestamp, mode, true)
          return response
        else
          @logger.error{"failed request (401 - unauthorized): #{query}"}
          raise Buzzn::DataSourceError.new('unauthorized to get data from discovergy: ' + response.body)
        end
      else
        raise Buzzn::DataSourceError.new('unable to get data from discovergy: ' + response.body)
      end
    end

    def create_virtual_meter(existing_random_broker, meter_ids_plus, meter_ids_minus=[], retried=false)
      access_token = build_access_token_from_broker_or_new(existing_random_broker)
      query = '/public/v1/virtual_meter?'
      if meter_ids_plus.any?
        query += 'meterIdsPlus=' + meter_ids_plus.sort!.join(",")
        if meter_ids_minus.any?
          query += '&'
        end
      end
      if meter_ids_minus.any?
        query += 'meterIdsMinus=' + meter_ids_minus.sort!.join(",")
      end
      access_token.post(query)
      response = access_token.response

      case response.code.to_i
      when (200..299)
        return response
      when 401
        if !retried
          register_application
          access_token = build_access_token_from_broker_or_new(existing_random_broker, true)
          response = self.create_virtual_meter(existing_random_broker, meter_ids_plus, meter_ids_minus, true)
        else
          raise Buzzn::DataSourceError.new('unauthorized to create virtual meter at discovergy: ' + response.body)
        end
      else
        raise Buzzn::DataSourceError.new('unable to create virtual meter at discovergy: ' + response.body)
      end
      return response.body
    end

    def virtual_meter_info(broker, retried=false)
      access_token = build_access_token_from_broker_or_new(broker)
      meter_id = broker.external_id
      query = '/public/v1/virtual_meter?meterId=' + meter_id
      access_token.get(query)
      response = access_token.response
      case response.code.to_i
      when (200..299)
        return response
      when 401
        if !retried
          register_application
          access_token = build_access_token_from_broker_or_new(broker, true)
          response = self.virtual_meter_info(broker, true)
        else
          raise Buzzn::DataSourceError.new('unauthorized to get data from discovergy: ' + response.body)
        end
      else
        raise Buzzn::DataSourceError.new('unable to get data from discovergy: ' + response.body)
      end
      return response
    end


    # This function checks if the broker contains information to use an existing token or if a new one must be requested
    # input params:
    #   broker: Broker::Discovergy which will be used to create or get an access token
    # returns:
    #   OAuth::AccessToken with information from the DB or new one
    def build_access_token_from_broker_or_new(broker, force_new=false)
      access_token = nil
      @lock.synchronize("#{LOCK_KEY}.#{broker.provider_login}", initial_wait: 0.5, retries: 11, ttl: 10) do
        if (broker.consumer_key && broker.consumer_secret && broker.provider_token_key && broker.provider_token_secret) && !force_new
          token_hash = {
            :oauth_token          => broker.provider_token_key,
            "oauth_token"         => broker.provider_token_key,
            :oauth_token_secret   => broker.provider_token_secret,
            "oauth_token_secret"  => broker.provider_token_secret
          }
          consumer = OAuth::Consumer.new(
            broker.consumer_key,
            broker.consumer_secret,
            :site => @url,
            :request_token_path => '/public/v1/oauth1/request_token',
            :authorize_path => '/public/v1/oauth1/authorize',
            :access_token_path => '/public/v1/oauth1/access_token'
          )
          access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
        else
          access_token = oauth1_process(broker)
          Broker::Discovergy.where(provider_login: broker.provider_login).update_all(
            :encrypted_provider_token_key => Broker::Discovergy.encrypt_provider_token_key(
              access_token.token,
              key: Rails.application.secrets.attr_encrypted_key
            ),
            :encrypted_provider_token_secret => Broker::Discovergy.encrypt_provider_token_secret(
              access_token.secret,
              key: Rails.application.secrets.attr_encrypted_key
            ),
            consumer_key: broker.consumer_key,
            consumer_secret: broker.consumer_secret
          )
          broker.reload
        end
      end
      return access_token
    end



    ################################
    ###     OAUTH 1 PROCESS      ###
    ################################

    def oauth1_process(broker)
      request_token = get_request_token(broker)
      verifier = authorize(broker, request_token)
      access_token = get_access_token(broker, request_token, verifier)
      access_token
    end

    def register_application
      conn = Faraday.new(:url => @url, ssl: {verify: false}, request: {timeout: TIMEOUT, open_timeout: TIMEOUT}) do |faraday|
        faraday.request  :url_encoded
        # TODO use Buzzn::Logger here
        faraday.response :logger, Rails.logger if Rails.env == 'development'
        faraday.adapter :net_http
      end
      response = conn.post do |req|
        req.url '/public/v1/oauth1/consumer_token'
        req.headers['Content-Type'] = "application/x-www-form-urlencoded"
        req.params['client'] = "buzzn app #{Rails.env}"
      end
      if !response.success?
        raise Buzzn::DataSourceError.new('unable to register at discovergy')
      end
      json_response = MultiJson.load(response.body)
      key = json_response['key']
      secret = json_response['secret']
      if key.nil? || secret.nil?
        raise Buzzn::DataSourceError.new('unable to parse data from discovergy')
      end
      return [key, secret]
    end

    def get_request_token(broker)
      key = broker.consumer_key
      secret = broker.consumer_secret
      if !key || !secret
        key, secret = register_application
        broker.consumer_key = key
        broker.consumer_secret = secret
      end
      begin
        consumer = OAuth::Consumer.new(
          key,
          secret,
          :site => @url,
          :request_token_path => '/public/v1/oauth1/request_token',
          :authorize_path => '/public/v1/oauth1/authorize',
          :access_token_path => '/public/v1/oauth1/access_token'
        )
        request_token = consumer.get_request_token
      rescue OAuth::Unauthorized
        key, secret = register_application
        broker.consumer_key = key
        broker.consumer_secret = secret
        retry
        # NOTE: maybe to not get lost in a dead lock we should count the retries
        #       but there is no case in which two calls with different consumers would throw this error
      end
      if !request_token
        raise Buzzn::DataSourceError.new('unable to get refresh token from discovergy')
      end
      return request_token
    end

    def authorize(broker, request_token)
      email = broker.provider_login
      password = broker.provider_password
      if !request_token
        request_token = get_request_token(broker)
      end
      conn = Faraday.new(:url => @url, ssl: {verify: false}, request: {timeout: TIMEOUT, open_timeout: TIMEOUT}) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger, Rails.logger if Rails.env == 'development'
        faraday.adapter :net_http
      end
      response = conn.get do |req|
        req.url '/public/v1/oauth1/authorize'
        req.headers['Content-Type'] = 'text/plain'
        req.params['oauth_token'] = request_token.token
        req.params['email'] = email
        req.params['password'] = password
      end
      if !response.success?
        raise Buzzn::DataSourceError.new('authorization failed at discovergy: ' + response.body)
      end
      return response.body.split('=')[1]
    end

    def get_access_token(broker, request_token, verifier)
      email = broker.provider_login
      password = broker.provider_password
      if !request_token
        request_token = get_request_token(broker)
      end
      if !verifier
        verifier = authorize(broker, request_token)
      end
      access_token = request_token.get_access_token(:oauth_verifier => verifier)
      if !access_token
        raise Buzzn::DataSourceError.new('unable to get access token from discovergy')
      end
      return access_token
    end






    [:register_application, :get_request_token, :authorize, :get_access_token, :readings,
      :create_virtual_meter, :virtual_meter_info, :single_reading].each do |method|

      alias :"do_#{method}" :"#{method}"

      define_method method do |*args|
        begin
          before
          send(:"do_#{method}", *args)
        ensure
          after
        end
      end

      private :"do_#{method}"
    end

    def before
      ActiveRecord::Base.clear_active_connections!
      @throughput.increment
      if @throughput.current > @max_concurrent
        raise Buzzn::DataSourceError.new('discovergy limit reached')
      end
    end

    def after
      @throughput.decrement
    end

  end
end
