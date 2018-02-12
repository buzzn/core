require_relative 'abstract_registers_builder'

class Discovergy::BubbleBuilder < Discovergy::AbstractRegistersBuilder

  def build(response)
    response.collect do |id, values|
      register = map[id]
      # Unfortunately our and Discovergy's list of meters can get out of sync as of now.
      # We skip meters we don't know about to prevent an error. See
      # https://github.com/buzzn/core/pull/1338/files for details.
      next unless register
      build_bubble(register, values)
    end.flatten.compact.uniq
  end

  private

  def build_bubble(register, values)
    Bubble.new(value: to_watt(values, register), register: register)
  end

end
