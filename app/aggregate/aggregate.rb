require 'uri'
#### Usage
# r = Register::Base.find('some-id')
# hash = Aggregate.sort_registers([r])
# a = Aggregate.new(hash)
# a.past
# a.past(timestamp: Time.current, resolution: 'year_to_months')

class Aggregate

  def self.build_cache_id(api_endpoint, register_ids, timestamp, resolution)
    timehash = Reading.time_range_from_timestamp_and_resolution(timestamp, resolution)
    params = {
      register_ids: register_ids,
      time: timehash
    }.to_param
    return "#{api_endpoint}?#{params}"
  end


  def initialize(registers_hash)
    @registers_hash = registers_hash
  end

  def present(params = {})
    timestamp = params.fetch(:timestamp, Time.current) || Time.current
    present_items = []



    @registers_hash[:buzzn_api].each do |register|
      document = Reading.where(meter_id: register.meter.id).order(timestamp: 'desc').first
      if document
        present_items << {
          "operator" => (register.mode == 'in' ? '+' : '-'),
          "data" => document_to_hash(register, document)
        }
      end
    end

    # discovergy
    @registers_hash[:discovergy].each do |register|
      present_items << {
        "operator" => (register.mode == 'in' ? '+' : '-'),
        "data" => external_data_live(register)
      }
    end

    [:slp, :sep_bhkw, :sep_pv].each do |fake_type|
      if @registers_hash[fake_type.to_sym].any?
        present_items.concat(present_fake(fake_type, @registers_hash, timestamp ))
      end
    end

    @registers_hash[:virtual].each do |register|
      formula_parts         = FormulaPart.where(register_id: register.id)
      register_ids    = formula_parts.map(&:operand_id)
      registers       = Register::Base.find(register_ids)
      registers_hash  = Aggregate.sort_registers(registers)

      if registers_hash[:data_sources].size > 1
        return 'error different data_sources'
      else
        data_source = registers_hash[:data_sources].first
        registers_hash[data_source.to_sym].each do |register|
          formula_part = formula_parts.find_by(operand_id: register.id)
          if formula_part.operator == '+'
            negativ = false
          elsif formula_part.operator == '-'
            negativ = true
          end
          present_items << {
            "operator" => (register.mode == 'in' ? '+' : '-'),
            "data" => send("present_#{data_source}", register, negativ)
          }
        end
      end
    end


    power_milliwatt_summed = 0
    present_items.each do |present_item|
      power_milliwatt_summed += present_item['data']['power_milliwatt'] if present_item['data']['power_milliwatt'] != nil
    end


    present = {
      "power_milliwatt" => power_milliwatt_summed,
      "readings" => present_items
    }
    if present_items.empty?
      present["timestamp"] = Time.current.utc(0)
    else
      present["timestamp"] = present_items.first['data']['timestamp']
    end

    return present
  end





  def past(params = {})
    timestamp  = params.fetch(:timestamp, Time.current) || Time.current
    resolution = params.fetch(:resolution, 'day_to_minutes') || 'day_to_minutes'
    refresh_cache = params.fetch(:refresh_cache, false) || false
    past_items = []
    register_ids = @registers_hash[:ids].join(',')
    cache_id = Aggregate.build_cache_id('/aggregates/past', register_ids, timestamp, resolution)

    if Rails.cache.exist?(cache_id) && !refresh_cache
      past = Rails.cache.fetch(cache_id)
    else

      # buzzn_api
      @registers_hash[:buzzn_api].each do |register|
        past_items << past_buzzn_api(register, resolution, timestamp)
      end

      # discovergy
      @registers_hash[:discovergy].each do |register|
        past_items << past_discovergy(register, resolution, timestamp)
      end

      [:slp, :sep_bhkw, :sep_pv].each do |fake_type|
        if @registers_hash[fake_type.to_sym].any?
          past_items.concat( past_fake(fake_type, @registers_hash, resolution, timestamp) )
        end
      end

      @registers_hash[:virtual].each do |register|
        formula_parts         = FormulaPart.where(register_id: register.id)
        register_ids    = formula_parts.map(&:operand_id)
        registers       = Register::Base.find(register_ids)
        registers_hash  = Aggregate.sort_registers(registers)

        if registers_hash[:data_sources].size > 1
          return 'error different data_sources'
        else
          data_source = registers_hash[:data_sources].first
          registers_hash[data_source.to_sym].each do |register|
            formula_part = formula_parts.find_by(operand_id: register.id)
            if formula_part.operator == '+'
              negativ = false
            elsif formula_part.operator == '-'
              negativ = true
            end
            past_items << send("past_#{data_source}", register, resolution, timestamp, negativ)
          end
        end
      end

      past = sum_lists(past_items, resolution)

      Rails.cache.write(
        cache_id,
        past,
        expires_in: cache_expires_in(resolution, timestamp)
      )
    end

    return past
  end


  def self.sort_registers(registers)
    buzzn_api           = []
    discovergy          = []
    virtual             = []
    slp                 = []
    sep_bhkw            = []
    sep_pv              = []
    data_sources        = []
    register_ids  = []

    registers.each do |register|
      data_sources.push(register.data_source) unless data_sources.include?(register.data_source) && register.data_source
      register_ids << register.id
      case register.data_source
      when :buzzn_api
        buzzn_api << register
      when :discovergy
        discovergy << register
      when :virtual
        virtual << register
      when :slp
        slp << register
      when :sep_bhkw
        sep_bhkw << register
      when :sep_pv
        sep_pv << register
      else
        Rails.logger.error "You gave me #{register.data_source} -- I have no idea what to do with that."
      end
    end

    hash = {
      buzzn_api: buzzn_api,
      discovergy: discovergy,
      virtual: virtual,
      slp: slp,
      sep_bhkw: sep_bhkw,
      sep_pv: sep_pv,
      data_sources: data_sources,
      ids: register_ids
    }

    return hash
  end



private

  def cache_expires_in(resolution, timestamp)
    immutable = 5.days
    case resolution
    when 'hour_to_minutes'
      timestamp.hour < Time.current.hour ? immutable : 15.minute
    when 'day_to_minutes'
      timestamp.day < Time.current.day ? immutable : 15.minute
    when 'month_to_days'
      timestamp.month < Time.current.month ? immutable : 1.day
    when 'year_to_months'
      timestamp.year < Time.current.year ? immutable : 1.day
    end
  end


  def present_fake(fake_type, registers_hash, timestamp )
    document = Reading.where(:timestamp.gte => timestamp, source: fake_type).first
    present_items = []
    registers_hash[fake_type.to_sym].each do |register|
      factor = factor_from_register(register)
      present_items << {
        "operator"  => "+",
        "data"      => document_to_hash(register, document, factor)
      }
    end
    return present_items
  end

  def present_discovergy(register, negativ=false)
    return external_data_live(register, negativ)
  end

  def past_buzzn_api(register, resolution, timestamp)
    source = { meter_id: { "$in" => [register.meter.id] } }
    keys = [required_reading_attributes(resolution, register)]
    collection = Reading.aggregate(resolution, source, timestamp, keys)
    return aggregation_to_hash(collection, 1, register.mode == 'in' ? false : true)
  end

  def past_discovergy(register, resolution, timestamp, negativ=false)
    return external_data(register, resolution, timestamp.to_i*1000, negativ)
  end

  def past_fake(fake_type, registers_hash, resolution, timestamp)
    source = { source: { "$in" => [fake_type] } }
    if Reading.energy_resolutions.include?(resolution)
      keys = ['energy_a_milliwatt_hour']
    elsif Reading.power_resolutions.include?(resolution)
      keys = ['power_a_milliwatt']
    end
    collection = Reading.aggregate(resolution, source, timestamp, keys)
    past_items = []
    registers_hash[fake_type.to_sym].each do |register|
      factor = factor_from_register(register)
      past_items << aggregation_to_hash(collection, factor, false)
    end
    return past_items
  end





  def factor_from_register(register)
     register.forecast_kwh_pa ? (register.forecast_kwh_pa/1000.0) : 1
  end

  def required_register(register)
    directions  = register.meter.registers.count
    if directions == 1 && register.input?
      register = 'a'
    elsif directions == 1 && register.output?
      register = 'a'
    elsif directions == 2 && register.input?
      register = 'a'
    elsif directions == 2 && register.output?
      register = 'b'
    end
    return register
  end

  def required_reading_attributes(resolution, register)
    register = required_register(register)
    if Reading.energy_resolutions.include?(resolution)
      return "energy_#{register}_milliwatt_hour"
    elsif Reading.power_resolutions.include?(resolution)
      return "power_#{register}_milliwatt"
    end
  end



  def sum_lists(lists, resolution)
    return [] if lists.empty?
    valueKey = :power_milliwatt
    if resolution == 'year_to_months' || resolution == 'month_to_days'
      valueKey = :energy_milliwatt_hour
    end
    result = []
    for i in 0...lists.size
      for j in 0...lists[i].size
        if lists[i][j]
          key = lists[i][j].values[0] #TODO the key is a value. please rename key
          value = lists[i][j].values[1]
          if i > 0
            timestampIndex = findMatchingTimestamp(key, result, resolution)
            if timestampIndex == -1
              result.push({timestamp: key, "#{valueKey}": value})
            else
              result[timestampIndex][valueKey] += value
            end
          else
            result.push({timestamp: key, "#{valueKey}": value})
          end
        end
      end
    end
    return result.sort! {|a, b| a[:timestamp] <=> b[:timestamp]}
  end

  def findMatchingTimestamp(key, arr, resolution)
    for i in 0...arr.size
      if resolution == 'year_to_months'
        if key >= arr[i][:timestamp].beginning_of_month && key <= arr[i][:timestamp].end_of_month
          return i
        end
      elsif resolution == 'month_to_days'
        if key >= arr[i][:timestamp].beginning_of_day && key <= arr[i][:timestamp].end_of_day
          return i
        end
      elsif resolution == 'day_to_minutes' #15 minutes
        if (key - arr[i][:timestamp]).abs < 450
          return i
        end
      elsif resolution == 'hour_to_minutes' || resolution == 'present' #2 seconds
        if (key - arr[i][:timestamp]).abs < 2
          return i
        end
      end
    end
    return -1
  end






  def aggregation_to_hash(collection, factor=1, negativ=false)
    items = []

    # TODO DRY this
    collection.each do |document|
      item = {'timestamp' => document['firstTimestamp']}

      if document['sumEnergyAMilliwattHour']
        energy_a_milliwatt_hour = document['sumEnergyAMilliwattHour'] * factor
        energy_a_milliwatt_hour *= -1 if negativ
        item.merge!('energy_a_milliwatt_hour' => energy_a_milliwatt_hour)
      end

      if document['sumEnergyBMilliwattHour']
        energy_b_milliwatt_hour = document['sumEnergyBMilliwattHour'] * factor
        energy_b_milliwatt_hour *= -1 if negativ
        item.merge!('energy_b_milliwatt_hour' => energy_b_milliwatt_hour)
      end

      if document['avgPowerAMilliwatt']
        power_a_milliwatt = document['avgPowerAMilliwatt'] * factor
        power_a_milliwatt *= -1 if negativ
        item.merge!('power_a_milliwatt' => power_a_milliwatt)
      end

      if document['avgPowerBMilliwatt']
        power_b_milliwatt = document['avgPowerBMilliwatt'] * factor
        power_b_milliwatt *= -1 if negativ
        item.merge!('power_b_milliwatt' => power_b_milliwatt)
      end

      items << item
    end
    return items
  end


  def document_to_hash(register, document, factor=1, negativ=false)
    item = {'timestamp' => document['timestamp']}
    if register.smart?
      x_ = register.input? ? 'a_' : 'b_'
    else
      x_ = 'a_'
    end
    ["energy_#{x_}milliwatt_hour", "power_#{x_}milliwatt" ].each do |key|
      if document[key]
        value = document[key] * factor
        value *= -1 if negativ
        item.merge!(key.gsub(x_, '') => value)
      end
    end
    return item
  end


  def external_data_live(register, negativ=false)
    crawler = Crawler.new(register)
    result = crawler.live
    timestamp = Time.at(result[:timestamp]/1000)
    power_milliwatt = (result[:power]*1000).to_i
    power_milliwatt *= -1 if negativ
    item = {
      'timestamp' => timestamp,
      'power_milliwatt' => power_milliwatt
    }
    return item
  end


  def external_data(register, resolution, timestamp, negativ=false)
    crawler = Crawler.new(register)
    key = 'power'
    unit = 'milliwatt'
    case resolution
    when 'hour_to_minutes'
      results = crawler.hour(timestamp)
    when 'day_to_minutes'
      results = crawler.day(timestamp)
    when 'month_to_days'
      results = crawler.month(timestamp)
      key = 'energy'
      unit = 'milliwatt_hour'
    when 'year_to_months'
      results = crawler.year(timestamp)
      key = 'energy'
      unit = 'milliwatt_hour'
    end

    if results.empty?
      return []
    end

    if results.first.size == 2 && register.input?
      type_of_meter = 'in'
    elsif results.first.size == 2 && register.output?
      type_of_meter = 'out'
    elsif results.first.size == 3 && register.input?
      type_of_meter = 'in_out'
    end

    items = []
    results.each do |result|
      item = {'timestamp' => Time.at(result[0]/1000) }
      case type_of_meter
      when 'in'
        key_a   = "#{key}_a_#{unit}"
        value_a = (result[1]).to_i
        value_a *= -1 if negativ
        item.merge!(key_a => value_a)
      when 'out'
        key_b   = "#{key}_b_#{unit}"
        value_b = (result[1]).to_i
        value_b *= -1 if negativ
        item.merge!(key_b => value_b)
      when 'in_out'
        key_a   = "#{key}_a_#{unit}"
        value_a = (result[1]).to_i
        value_a *= -1 if negativ
        item.merge!(key_a => value_a)
        key_b   = "#{key}_b_#{unit}"
        value_b = (result[2]).to_i
        value_b *= -1 if negativ
        item.merge!(key_b => value_b)
      end
      items << item
    end

    return items
  end



end
