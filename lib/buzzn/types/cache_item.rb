require_relative '../types'

class Types::CacheItem

  extend Dry::Initializer

  option :json, Types::Strict::String
  option :digest, Types::Strict::String
  option :time_to_live, Types::Strict::Int

  attr_reader :expires_at

  def initialize(**kwargs)
    if kwargs[:json] && kwargs[:digest].nil?
      kwargs[:digest] = Digest::SHA256.base64digest(kwargs[:json])
    end
    super(kwargs)
    @expires_at = Time.at(Buzzn::Utils::Chronos.now.to_f + time_to_live)
  end

  def to_json(*); json; end

end
