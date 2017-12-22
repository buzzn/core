require_relative 'abstract_builder'

class Discovergy::BubbleBuilder < Discovergy::AbstractBuilder

  option :registers

  def build(response)
    response.collect do |id, values|
      serial = id.sub(/.*_/, '')
      register = registers.detect { |r| r.meter.product_serialnumber == serial }
      build_bubble(register.meter, values)
    end.flatten.compact.uniq
  end

  private

  def build_bubble(meter, values)
    if meter
      meter.registers.where(id: registers).collect do |register|
        Bubble.new(value: to_watt(values, register), register: register)
      end
    end
  end
end
