require_relative '../discovergy'

class Services::Datasource::Discovergy::Api

  class EmptyResponse < StandardError; end

  include Import['service.datasource.discovergy.oauth']
  include Import['service.datasource.discovergy.throughput']

  def initialize(**)
    super
    @logger = Buzzn::Logger.new(self)
  end

  def raw_request(query)
     monitored_request(query)
  end

  def request(query, builder = nil)
    payload = monitored_request(query)
    return if payload.empty?
    result = MultiJson.load(payload)

    if builder
      builder.build(result)
    else
      build(result)
    end
  end

  private

  def build(result)
    case result
    when Array; process_array(result)
    when Hash;  process_hash(result)
    else        raise 'not implemented'
    end
  end

  def process_hash(hash)
    hash.each do |key, value|
      case value
      when Hash;  hash[key] = process_hash(value)
      when Array; hash[key] = process_array(value)
      else        value
      end
    end
    OpenStruct.new(hash)
  end

  def process_array(array)
    case array.first
    when NilClass; []
    when Hash;     array.collect { |v| process_hash(v) }
    else           array
    end
  end

  def monitored_request(query)
    begin
      throughput.increment!

      do_request(query, true)

    ensure
      throughput.decrement
    end
  end

  def do_request(query, first)
    token = oauth.access_token_create

    token.send(query.http_method, query.to_uri(oauth.path))
    response = token.response

    case response.code.to_i
    when (200..299)
      response.body
    when 401
      if first
        oauth.reset
        do_request(query, false)
      else
        raise Buzzn::DataSourceError.new('unauthorized to get data from discovergy: ' + response.body)
      end
    else
      raise Buzzn::DataSourceError.new('unable to get data from discovergy: ' + response.body)
    end
  rescue => e
    raise Buzzn::DataSourceError.new('unable to get data from discovergy: ' + e.message)
  end
end
