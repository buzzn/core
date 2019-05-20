require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../builders/discovergy'

class Services::Datasource::Discovergy::SingleReading

  include Import[api: 'services.datasource.discovergy.api',
                 rack_env: 'config.rack_env',
                 cache: 'services.cache']

  def all(group, date)
    meter = Meter::Discovergy.find_by(group: group)
    return unless meter
    api.request(
      query(meter, date, true),
      builder(group.registers, true)
    )
  end

  def next_key(register, date)
    "next#{register.id}#{date}"
  end

  def next_api_request_single(register, date, val)
    # this puts the raw value into the cache for that
    # the mock api should return for the next single()
    # request
    key = next_key(register, date)
    cache.put(key, val.to_json, 600)
  end

  def single(register, date)
    case rack_env.to_sym
    when :production, :development
      # byebug.byebug
      query = query(register.meter, date, false)
      key = "#{query.meter.product_serialnumber}-#{query.from}-#{query.to}-#{query.resolution}"
      item = cache.get(key)
      if item && !item.json.empty?
        puts '------'
        puts 'Cached reading:'
        puts MultiJson.load(item.json)
        puts '------'
        result = MultiJson.load(item.json)
      else
        result = api.request(
          query(register.meter, date, false),
          builder([register], false)
        )
        cache.put(key, result.to_json, 600000000)
        puts '------'
        puts 'Disco reading:'
        puts result.inspect
        puts '------'
        result
      end
    when :test
      key = next_key(register, date)
      item = cache.get(key)
      if item && !item.json.empty?
        result = MultiJson.load(item.json)
        unless result.nil? || result.empty?
          builder([register], false).build(result)
        end
      end
    end
  end

  private

  def query(meter, date, virtual)
    params = {
      meter:  meter,
      fields: [:energy, :energyOut],
      # get a bunch of values around the requested date, in case those exactly on the date aren't available
      from:   as_unix_timestamp_ms(date - 1.hours),
      to:     as_unix_timestamp_ms(date + 1.hours),
      resolution: :fifteen_minutes
    }.tap do |x|
      if virtual
        x[:each] = true
      end
    end
    Types::Discovergy::Readings::Get.new(params)
  end

  def builder(registers, virtual)
    Builders::Discovergy::SingleReadingsBuilder.new(registers: registers, virtual: virtual)
  end

  # Discovergy requires an UNIX timestamp in ms
  def as_unix_timestamp_ms(date)
    date.to_i * 1_000
  end

end
