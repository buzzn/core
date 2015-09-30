# This file bundles all crawlers.
# it branches via meter.manufacturer_name to the respective API
# The first two json APIs, discovergy (https://my.discovergy.com/json/api/help) and flukso
# (old for amperix; http://www.flukso.net/files/flm02/manual.pdf) are quite similar in respect to input
# input is managed by faraday gem and self explaining.
# output differs also little:
# discovergy: each member of json array has a name, e.g. "time"
# amperix: each member of json array has no name position 1 is always time, position 2 is always power
# however authorisation strategy differs.
# discovergy: username -- password
# amperix: sensor-uuid -- x-token
# Also measurementmethod and intention of the devices differ but this is too much to tell here.
#
#
# subroutines implemented here are used by meteringpoints and groups
# for testing the respective API it is recomended to use amperix- and discovergy- crawlers directly as
# here meter, meteringpoint and metering_point_operator_contract must be declarated first.



# Discovergy
# metering_point = MeteringPoint.find('91b2c688-d73f-4fda-ae2b-c3a3f3db84e4')
# Benchmark.measure{ Crawler.new(metering_point).live }
# Benchmark.measure{ Crawler.new(metering_point).hour().count }
# Benchmark.measure{ Crawler.new(metering_point).day().count }
# Benchmark.measure{ Crawler.new(metering_point).month().count }


# Amperix


class Crawler

  def initialize(metering_point)
    @unixtime_now                     = Time.now.in_time_zone.utc.to_i*1000
    @metering_point                   = metering_point
    @metering_point_input             = @metering_point.input?
    @metering_points_size             = @metering_point.meter.metering_points.size
    @metering_point_operator_contract = @metering_point.metering_point_operator_contract
    @meter                            = @metering_point.meter
  end



  def live
    if @metering_point_operator_contract.organization.slug ==  "amperix"
      amperix  = Amperix.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = amperix.get_live
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
        puts request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_live(@meter.manufacturer_product_serialnumber)
      if request['status'] == "ok"
        if request['result'].any?
          request['result'].each do |item|
            timestamp = item['time']
            if @metering_point.meter.metering_points.size > 1
              if item['power'] > 0 && @metering_point.input?
                power = item['power']/1000
              elsif item['power'] < 0 && @metering_point.output?
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
          puts request.inspect
        end
      else
        puts request.inspect
      end
    end
    puts "THIS AINT neither DISCO nor Amperix"
  end







  def hour(containing_timestamp=@unixtime_now)
    result = []
    if @metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      amperix  = Amperix.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = amperix.get_hour(containing_timestamp)
      if request.any?
        request.each do |item|
          #puts item.to_s
          timestamp = item[0] * 1000
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            power = item[1] > 0 ? Integer(item[1].abs) : 0
            result << [timestamp, power]
          end
        end
      else
        puts request.inspect
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
              elsif item['power'] < 0 && !@metering_point_input
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
          puts request.inspect
       end
      else
        puts request.inspect
      end
    end
    return result
  end




  # returns array with 96 quarter hour values
  def day(containing_timestamp=@unixtime_now)
    result = []
    if @metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      amperix  = Amperix.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = amperix.get_day(containing_timestamp)
      if request.any?
        request.each do |item|
          #puts item.to_s
          timestamp = item[0] * 1000
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            power = item[1] > 0 ? Integer(item[1].abs) : 0
            result << [timestamp, power]
          end
        end
      else
        puts request.inspect
      end
    else
      discovergy  = Discovergy.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request     = discovergy.get_day(@meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?
          request['result'].each do |item|
            timestamp = item['timeStart']

            if @metering_points_size > 1
              if item['power'] > 0 && @metering_point_input
                power = item['power']/1000
              elsif item['power'] < 0 && !@metering_point_input
                power = item['power'].abs/1000
              else
                power = 0
              end
            else
              power = item['power'] > 0 ? Integer(item['power'].abs)/1000 : 0
            end

            timenew = Time.new.to_i - 50
            if timestamp/1000 < timenew
              result << [timestamp, power]
            end

          end
        else
          puts request.inspect
        end
      else
        puts request.inspect
      end
    end
    return result
  end








  def month(containing_timestamp=@unixtime_now)
    result = []
    if @metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      amperix  = Amperix.new(@metering_point_operator_contract.username, @metering_point_operator_contract.password)
      request  = amperix.get_month(containing_timestamp)
      if request.any?
        request.each do |item|
        #puts item.to_s
        timestamp = item[0] * 1000 - 720000 # GMT -2h
        if String.try_convert(item[1])== "-nan"
          item[1]=0
        else
          work = item[1] > 0 ? item[1].abs/365 : 0  # must be converted from kwhperyear to kwhperday
          result << [timestamp, work]
        end
      end
      else
        puts request.inspect
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
          if @metering_point.meter.metering_points.size > 1 && @metering_point.output?
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
          puts request.inspect
        end
      else
        puts request.inspect
      end
    end
    return result
  end





end

