require 'benchmark'
class Aggregate

  def initialize(metering_points_hash)
    @metering_points_hash = metering_points_hash
  end

  def present(params = {})
    @cache_id = "/aggregate/present?metering_point_ids=#{@metering_points_hash[:ids].join(',')}"
    if Rails.cache.exist?(@cache_id)
      @present = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @present_items = []
        @timestamp = params.fetch(:timestamp, Time.current) || Time.current

        @metering_points_hash[:buzzn_api].each do |metering_point|
          document = Reading.where(meter_id: metering_point.meter.id).order(timestamp: 'desc').first
          if document
            @present_items << {
              "operator" => (metering_point.mode == 'in' ? '+' : '-'),
              "data" => document_to_hash(document)
            }
          end
        end

        # discovergy
        @metering_points_hash[:discovergy].each do |metering_point|
          @present_items << {
            "operator" => (metering_point.mode == 'in' ? '+' : '-'),
            "data" => external_data_live(metering_point)
          }
        end

        ['slp', 'sep_bhkw', 'sep_pv'].each do |fake_type|
          if @metering_points_hash[fake_type.to_sym].any?
            @present_items.concat(present_fake(fake_type, @metering_points_hash, @timestamp ))
          end
        end

      end
    end

    power_milliwatt_summed = 0
    @present_items.each do |present_item|
      case present_item['operator']
      when '+'
        power_milliwatt_summed += present_item['data']['power_a_milliwatt']
      when '-'
        power_milliwatt_summed -= present_item['data']['power_a_milliwatt']
      else
        "You gave me operator: #{operator} -- I have no idea what to do with that."
      end
    end

    @present = {
      "readings" => @present_items,
      "power_milliwatt_summed" => power_milliwatt_summed
    }

    if seconds_to_process > 2
      Rails.cache.write(@cache_id, @present, expires_in: 5.seconds)
    end
    return @present
  end





  def past(params = {})

    @cache_id = "/aggregate/past?metering_point_ids=#{@metering_points_hash[:ids].join(',')}&timestamp=#{@timestamp}&resolution=#{@resolution}"
    if Rails.cache.exist?(@cache_id)
      @past = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @past_items = []
        @timestamp  = params.fetch(:timestamp, Time.current) || Time.current
        @resolution = params.fetch(:resolution, 'day_to_minutes') || 'day_to_minutes'

        # buzzn_api
        @metering_points_hash[:buzzn_api].each do |metering_point|
          @past_items << past_buzzn_api(metering_point, @resolution, @timestamp)
        end

        # discovergy
        @metering_points_hash[:discovergy].each do |metering_point|
          @past_items << past_discovergy(metering_point, @resolution, @timestamp)
        end

        ['slp', 'sep_bhkw', 'sep_pv'].each do |fake_type|
          if @metering_points_hash[fake_type.to_sym].any?
            @past_items.concat( past_fake(fake_type, @metering_points_hash, @resolution, @timestamp) )
          end
        end

        @metering_points_hash[:virtual].each do |metering_point|
          metering_point_ids    = FormulaPart.where(metering_point_id: metering_point.id).map(&:operand_id)
          metering_points       = MeteringPoint.find(metering_point_ids)
          metering_points_hash  = Aggregate.sort_metering_points(metering_points)

          if metering_points_hash[:data_sources].size > 1
            return 'error different data_sources'
          else
            data_source = metering_points_hash[:data_sources].first
            metering_points_hash[data_source.to_sym].each do |metering_point|
              @past_items << send("past_#{data_source}", metering_point, @resolution, @timestamp)
            end
          end
        end

        @past = sum_lists(@past_items)

      end
      if seconds_to_process > 2
        Rails.cache.write(@cache_id, @past, expires_in: 1.minute)
      end
    end
    return @past
  end



  def self.sort_metering_points(metering_points)
    buzzn_api           = []
    discovergy          = []
    virtual             = []
    slp                 = []
    sep_bhkw            = []
    sep_pv              = []
    data_sources        = []
    metering_point_ids  = []

    metering_points.each do |metering_point|
      data_sources.push(metering_point.data_source) unless data_sources.include?(metering_point.data_source)
      metering_point_ids << metering_point.id
      case metering_point.data_source
      when 'buzzn_api'
        buzzn_api << metering_point
      when 'discovergy'
        discovergy << metering_point
      when 'virtual'
        virtual << metering_point
      when 'slp'
        slp << metering_point
      when 'sep_bhkw'
        sep_bhkw << metering_point
      when 'sep_pv'
        sep_pv << metering_point
      else
        Rails.logger.error "You gave me #{metering_point.data_source} -- I have no idea what to do with that."
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
      ids: metering_point_ids
    }

    return hash
  end



private

  def present_fake(fake_type, metering_points_hash, timestamp )
    document = Reading.where(:timestamp.gte => timestamp, source: fake_type).first
    present_items = []
    metering_points_hash[fake_type.to_sym].each do |metering_point|
      factor = factor_from_metering_point(metering_point)
      present_items << {
        "operator"  => "+",
        "data"      => document_to_hash(document, factor)
      }
    end
    return present_items
  end


  def past_buzzn_api(metering_point, resolution, timestamp)
    source = { meter_id: { "$in" => [metering_point.meter.id] } }
    keys = [required_reading_attributes(resolution, metering_point)]
    collection = Reading.aggregate(resolution, source, timestamp, keys)
    return aggregation_to_hash(collection, 1, metering_point.mode == 'in' ? false : true)
  end

  def past_discovergy(metering_point, resolution, timestamp)
    return external_data(metering_point, resolution, timestamp.to_i*1000)
  end

  def past_fake(fake_type, metering_points_hash, resolution, timestamp)
    source = { source: { "$in" => [fake_type] } }
    if Reading.energy_resolutions.include?(@resolution)
      keys = ['energy_a_milliwatt_hour']
    elsif Reading.power_resolutions.include?(@resolution)
      keys = ['power_a_milliwatt']
    end
    collection = Reading.aggregate(@resolution, source, @timestamp, keys)
    past_items = []
    metering_points_hash[fake_type.to_sym].each do |metering_point|
      factor = factor_from_metering_point(metering_point)
      past_items << aggregation_to_hash(collection, factor, false)
    end
    return past_items
  end





  def factor_from_metering_point(metering_point)
     metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/1000) : 1
  end

  def required_register(metering_point)
    directions  = metering_point.meter.metering_points.count
    if directions == 1 && metering_point.input?
      register = 'a'
    elsif directions == 1 && metering_point.output?
      register = 'a'
    elsif directions == 2 && metering_point.input?
      register = 'a'
    elsif directions == 2 && metering_point.output?
      register = 'b'
    end
    return register
  end

  def required_reading_attributes(resolution, metering_point)
    register = required_register(metering_point)
    if Reading.energy_resolutions.include?(resolution)
      return "energy_#{register}_milliwatt_hour"
    elsif Reading.power_resolutions.include?(resolution)
      return "power_#{register}_milliwatt"
    end
  end



  def sum_lists(lists)
    if lists.count > 1
      tamplate_list  = lists.pop
      keys           = tamplate_list.first.keys
      keys.delete('timestamp')
      lists.each do |list|
        list.each_with_index do |item, index|
          keys.each do |key|
            tamplate_list[index][key] += item[key]
          end
        end
      end
      return tamplate_list

    else
      return lists.first

    end
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


  def document_to_hash(document, factor=1, negativ=false)
    item = {'timestamp' => document['timestamp']}
    ['energy_a_milliwatt_hour', 'energy_b_milliwatt_hour', 'power_a_milliwatt', 'power_b_milliwatt'].each do |key|
      if document[key]
        value = document[key] * factor
        value * -1 if negativ
        item.merge!(key => value)
      end
    end
    return item
  end


  def external_data_live(metering_point)
    crawler = Crawler.new(metering_point)
    result = crawler.live
    item = {
      'timestamp' => Time.at(result[:timestamp]/1000),
      'power_a_milliwatt' => (result[:power]*1000).to_i
    }
    return item
  end


  def external_data(metering_point, resolution, timestamp)
    crawler = Crawler.new(metering_point)

    case resolution
    when 'hour_to_minutes'
      results = crawler.hour(timestamp)
    when 'day_to_minutes'
      results = crawler.day(timestamp)
    when 'month_to_days'
      results = crawler.month(timestamp)
    when 'year_to_months'
      results = crawler.year(timestamp)
    end

    if results.first.size == 2 && metering_point.input?
      type_of_meter = 'in'
    elsif results.first.size == 2 && metering_point.output?
      type_of_meter = 'out'
    elsif results.first.size == 3 && metering_point.input?
      type_of_meter = 'in_out'
    end

    items = []
    results.each do |result|
      item = {'timestamp' => Time.at(result[0]/1000) }
      case type_of_meter
      when 'in'
        item.merge!('energy_a_milliwatt_hour' => (result[1]*1000).to_i)
      when 'out'
        item.merge!('energy_b_milliwatt_hour' => (result[1]*1000*-1).to_i)
      when 'in_out'
        item.merge!('energy_a_milliwatt_hour' => (result[1]*1000).to_i)
        item.merge!('energy_b_milliwatt_hour' => (result[2]*1000*-1).to_i)
      end
      items << item
    end

    return items
  end



end
