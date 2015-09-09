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

class Crawler
  def getDataLive(metering_point, metering_point_operator_contract, meter)
  # result = []
    # puts metering_point_operator_contract.organization.slug
    #if metering_point.meter.manufacturer_name ==  "amperix" # meter.name== 'Amperix'
    if metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      #puts "Amperix Live"
      amperix  = Amperix.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request  = amperix.get_live
      if request.any?
        request.each do |item|
          timestamp = item[0] * 1000
          if String.try_convert(item[1])== "-nan"
            item[1]=0
          else
            power = item[1] > 0 ? Integer(item[1].abs) : 0
          #  result << [timestamp, power]
          end
          return {:power => power, :timestamp => timestamp}
        end
      else
        puts request.inspect
      end
    else
      # puts "Discovergy Live"
      discovergy  = Discovergy.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request     = discovergy.get_live(meter.manufacturer_product_serialnumber, 4)
      if request['status'] == "ok"
        if request['result'].any?

          request['result'].each do |item|
            timestamp = item['time']
            if metering_point.meter.metering_points.size > 1
              if item['power'] > 0 && metering_point.input?
                power = item['power']/1000
              elsif item['power'] < 0 && metering_point.output?
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
    # return result
  end



  def getDataHour(containing_timestamp, metering_point, metering_point_operator_contract, meter)
    result = []
    if metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      amperix  = Amperix.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
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
      discovergy  = Discovergy.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request     = discovergy.get_hour(meter.manufacturer_product_serialnumber,containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?
          # TODO: make this nicer
          request['result'].each do |item|
           # puts item.to_s
            if metering_point.meter.metering_points.size > 1
              if item['power'] > 0 && metering_point.input?
                power = item['power']/1000
              elsif item['power'] < 0 && metering_point.output?
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



  def getDataMonth(containing_timestamp, metering_point, metering_point_operator_contract, meter)
    result = []
    if metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      amperix  = Amperix.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request     = amperix.get_month(containing_timestamp)
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
      discovergy  = Discovergy.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request     = discovergy.get_month(meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?
          # TODO: make this nicer
          old_value = -1
          new_value = -1
          timestamp = -1
          i = 0
          if metering_point.meter.metering_points.size > 1 && metering_point.output?
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


  # returns array with 96 quarter hour values
  def getDataDay(containing_timestamp, metering_point, metering_point_operator_contract, meter)
    result = []
    if metering_point_operator_contract.organization.slug ==  "amperix" # meter.name== 'Amperix'
      amperix  = Amperix.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request     = amperix.get_day(containing_timestamp)
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
      discovergy  = Discovergy.new(metering_point_operator_contract.username, metering_point_operator_contract.password)
      request     = discovergy.get_day(meter.manufacturer_product_serialnumber, containing_timestamp)
      if request['status'] == "ok"
        if request['result'].any?
          # TODO: make this nicer

          request['result'].each do |item|
            timestamp = item['timeStart']
            if metering_point.meter.metering_points.size > 1
              if item['power'] > 0 && metering_point.input?
                power = item['power']/1000
              elsif item['power'] < 0 && metering_point.output?
                power = item['power'].abs/1000
              else
                power = 0
              end
            else
              power = item['power'] > 0 ? Integer(item['power'].abs)/1000 : 0
            end
            #puts Time.new.to_i.to_s + ":   " + (timestamp/1000).to_s
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
end

