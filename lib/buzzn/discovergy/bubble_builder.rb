require_relative 'abstract_builder'

class Discovergy::BubbleBuilder < Discovergy::AbstractBuilder

  option :meters

  def build(response)
    response.collect do |id, values|
      build_bubble(id, values)
    end.compact
  end

  private

  def build_bubble(id, values)
    serial = id.sub(/.*_/, '')
    meter = meters.detect { |m| m.product_serialnumber == serial }
    if meter
      Bubble.new(value: to_watt(values), register: meter.registers.first)
    end
  end
end
