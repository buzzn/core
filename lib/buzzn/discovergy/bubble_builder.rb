require_relative 'abstract_builder'

class Discovergy::BubbleBuilder < Discovergy::AbstractBuilder

  option :meters

  def build(response)
    response.collect do |id, values|
      serial = id.sub(/.*_/, '')
      meter = meters.detect { |m| m.product_serialnumber == serial }
      build_bubble(meter, values)
    end.flatten.compact.uniq
  end

  private

  def build_bubble(meter, values)
    if meter
      meter.registers.collect do |register|
        Bubble.new(value: to_watt(values, register), register: register)
      end
    end
  end
end
