# This file bundles all crawlers.
# it branches via meter.manufacturer_name to the respective API
# The first two json APIs, discovergy (https://my.discovergy.com/json/api/help) and flukso
# (old for my_smart_grid; http://www.flukso.net/files/flm02/manual.pdf) are quite similar in respect to input
# input is managed by faraday gem and self explaining.
# output differs also little:
# discovergy: each member of json array has a name, e.g. "time"
# my_smart_grid: each member of json array has no name position 1 is always time, position 2 is always power
# however authorisation strategy differs.
# discovergy: username -- password
# my_smart_grid: sensor-uuid -- x-token
# Also measurementmethod and intention of the devices differ but this is too much to tell here.
#
#
# subroutines implemented here are used by meteringpoints and groups
# for testing the respective API it is recomended to use my_smart_grid- and discovergy- crawlers directly as
# here meter, meteringpoint and metering_point_operator_contract must be declarated first.



# Discovergy
# metering_point = MeteringPoint.find('b192b036-24ba-467a-906c-d4f642566c54')
# Benchmark.measure{ Crawler.new(metering_point).live }
# Benchmark.measure{ Crawler.new(metering_point).hour().count }
# Benchmark.measure{ Crawler.new(metering_point).day().count }
# Benchmark.measure{ Crawler.new(metering_point).month().count }
# Crawler.new(metering_point).valid_credential?



class Crawler

  def initialize(metering_point)
    @unixtime_now                     = Time.now.in_time_zone.utc.to_i*1000
    @metering_point                   = metering_point
    raise ArgumentError.new("no metering_point_operator_contract on metering_point") unless @metering_point.metering_point_operator_contract
    @metering_point_operator_contract = @metering_point.metering_point_operator_contract
    @metering_point_operator          = @metering_point_operator_contract.organization.slug
    @metering_point_input             = @metering_point.input?
    @metering_point_output            = @metering_point.output?
    raise ArgumentError.new("no meter on metering_point") unless @metering_point.meter
    @meter                            = @metering_point.meter
    @metering_points_size             = @meter.metering_points.size
  end

  def valid_credential?
    case @metering_point_operator

    when 'discovergy'
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_live(@meter.manufacturer_product_serialnumber)
      return request['status'] == 'ok'

    when 'buzzn-metering'
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_live(@meter.manufacturer_product_serialnumber)
      return request['status'] == 'ok'

    when 'my_smart_grid'
      my_smart_grid = MySmartGrid.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request = my_smart_grid.get_live
      return request != ""

    else
      "You gave me #{@metering_point_operator} -- I have no idea what to do with that."
    end
  end

  def live
    if @metering_point_operator_contract.organization.slug ==  "mysmartgrid"
      my_smart_grid  = MySmartGrid.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = my_smart_grid.get_live
      if request.any?
        request.each do |item|
          timestamp = item[0] * 1000
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            power = item[1] > 0 ? Integer(item[1].abs) : 0
          end
          return {:power => power, :timestamp => timestamp}
        end
      else
        logger.info request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_live(@meter.manufacturer_product_serialnumber)
      if request['status'] == "ok"
        if request['result'].any?
          request['result'].each do |item|
            timestamp = item['time']
            if @metering_points_size > 1
              if item['power'] > 0 && @metering_point_input
                power = item['power']/1000
              elsif item['power'] < 0 && @metering_point_output
                power = item['power'].abs/1000
              else
                power = 0
              end
            else
              power = item['power'] > 0 ? item['power'].abs/1000 : 0
            end
            return {:power => power, :timestamp => timestamp}
          end
        else
          logger.info request.inspect
        end
      else
        logger.info request.inspect
      end
    end
    logger.info "THIS AINT neither DISCO nor MySmartGrid"
  end


  def live_each
    if @metering_point_operator_contract.organization.slug == "mysmartgrid"
      #do something?
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_live_each(@meter.manufacturer_product_serialnumber)
      if request['status'] == "ok"
        if request['result'].any?
          result = []
          request['result'].each do |item|
            timestamp = item['time']
            power = item['power'].abs/1000
            meter_id = item['meterId'].split('_')[1]
            result << {:meter_id => meter_id, :timestamp => timestamp, :power => power}
          end
          return {:result => result}
        else
          logger.info request.inspect
        end
      else
        logger.info request.inspect
      end
    end
  end







  def hour(containing_timestamp=@unixtime_now)
    result = []
    if @metering_point_operator_contract.organization.slug ==  "mysmartgrid" # meter.name== 'MySmartGrid'
      my_smart_grid  = MySmartGrid.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = my_smart_grid.get_hour(containing_timestamp)
      if request.any?
        request.each do |item|
          #logger.info item.to_s
          timestamp = item[0] * 1000
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            power = item[1] > 0 ? Integer(item[1].abs) : 0
            result << [timestamp, power]
          end
        end
      else
        logger.info request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_hour(@meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?
          request['result'].each do |item|
            if @metering_points_size > 1
              if item['power'] > 0 && @metering_point_input
                power = item['power']/1000
              elsif item['power'] < 0 && @metering_point_output
                power = item['power'].abs/1000
              else
                power = 0
              end
            else
              power = item['power'] > 0 ? item['power'].abs/1000 : 0
            end
            timestamp = item['time']
            result << [timestamp, power]
          end
        else
          logger.info request.inspect
       end
      else
        logger.info request.inspect
      end
    end
    return result
  end




  # returns array with 96 quarter hour values
  def day(containing_timestamp=@unixtime_now)
    result = []
    if @metering_point_operator_contract.organization.slug ==  "mysmartgrid" # meter.name== 'MySmartGrid'
      my_smart_grid  = MySmartGrid.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = my_smart_grid.get_day(containing_timestamp)
      if request.any?
        request.each do |item|
          #logger.info item.to_s
          timestamp = item[0] * 1000
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            power = item[1] > 0 ? Integer(item[1].abs) : 0
            result << [timestamp, power]
          end
        end
      else
        logger.info request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_day(@meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?
          first_reading = first_timestamp = nil
          request['result'].each do |item|
            # timeStart = item['timeStart']
            # timeEnd = item['timeEnd']
            # i = 0
            # while timeStart + i * 6000 < timeEnd
            #   if @metering_points_size > 1
            #     if item['power'] > 0 && @metering_point_input
            #       power = item['power']/1000
            #     elsif item['power'] < 0 && @metering_point_output
            #       power = item['power'].abs/1000
            #     else
            #       power = 0
            #     end
            #   else
            #     power = item['power'] > 0 ? Integer(item['power'].abs)/1000 : 0
            #   end
            #   timestamp = timeStart + i * 6000
            #   timenew = Time.new.to_i - 50
            #   if timestamp/1000 < timenew
            #     result << [timestamp, power]
            #   end
            #   i += 1
            # end

            second_timestamp = item['time']
            if @metering_points_size > 1
              if @metering_point_input
                second_reading = item['energy']
              elsif @metering_point_output
                second_reading = item['energyOut']
              end
            else
              second_reading = item['energy']
            end

            if first_timestamp
              power = (second_reading - first_reading)/(2500000.0) # convert vsm to power
              result << [first_timestamp, power]
            end
            first_timestamp = second_timestamp
            first_reading = second_reading
          end
        else
          logger.info request.inspect
        end
      else
        logger.info request.inspect
      end
    end
    return result
  end








  def month(containing_timestamp=@unixtime_now)
  result = []
    if @metering_point_operator_contract.organization.slug ==  "mysmartgrid" # meter.name== 'MySmartGrid'
      my_smart_grid  = MySmartGrid.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = my_smart_grid.get_month(containing_timestamp)
      if request.any?
        request.each do |item|
        #logger.info item.to_s
        timestamp = item[0] * 1000 - 720000 # GMT -2h
        if String.try_convert(item[1])== "-nan"
          item[1]=0
        else
          work = item[1] > 0 ? item[1].abs/365 : 0  # must be converted from kwhperyear to kwhperday
          result << [timestamp, work]
        end
      end
      else
        logger.info request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_month(@meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?


          # TODO: make this nicer
          old_value = -1
          new_value = -1
          timestamp = -1
          i = 0
          if @metering_points_size > 1 && @metering_point_output
            mode = 'energyOut'
          else
            mode = 'energy'
          end

          request['result'].each do |item|
            if i == 0
              old_value = item[mode]
              timestamp = item['time']
              i += 1
              next
            end
            new_value = item[mode]
            result << [timestamp, (new_value - old_value)/10000000000.0]
            old_value = new_value
            timestamp = item['time']
            i += 1
          end
        else
          logger.info request.inspect
        end
      else
        logger.info request.inspect
      end
    end

    return result
  end


  def year(containing_timestamp=@unixtime_now)
  result = []
    if @metering_point_operator_contract.organization.slug ==  "mysmartgrid" # meter.name== 'MySmartGrid'
      my_smart_grid  = MySmartGrid.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = my_smart_grid.get_year(containing_timestamp)
      if request.any?
        request.each do |item|
          #logger.info item.to_s
          timestamp = item[0] * 1000 - 720000 # GMT -2h
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            work = item[1] > 0 ? item[1].abs*0.03287671232876712 : 0  # must be converted from kwhperyear to kwhpermonth
            result << [timestamp, work]
          end
        end
      else
        logger.info request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_year(@meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?


          # TODO: make this nicer
          old_value = -1
          new_value = -1
          timestamp = -1
          i = 0
          if @metering_points_size > 1 && @metering_point_output
            mode = 'energyOut'
          else
            mode = 'energy'
          end

          request['result'].each do |item|
            if i == 0
              old_value = item[mode]
              timestamp = Time.at(item['time']/1000).in_time_zone.beginning_of_month.to_i*1000
              #timestamp = item['time']
              i += 1
              next
            end

            if item['time'] == (Time.at(timestamp/1000).in_time_zone.end_of_month + 1.second).to_i*1000
              new_value = item[mode]
              result << [timestamp, (new_value - old_value)/10000000000.0]
              old_value = new_value
              timestamp = item['time']
            end
          end
          new_value = request['result'][request['result'].size - 1][mode]
          new_value != old_value ? result << [(Time.at(timestamp/1000).in_time_zone.beginning_of_month).to_i*1000, (new_value - old_value)/10000000000.0] : nil
        else
          logger.info request.inspect
        end
      else
        logger.info request.inspect
      end
    end

    return result
  end


end
