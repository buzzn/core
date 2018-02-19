require_relative 'base_resource'

module Register
  class SubstituteResource < BaseResource

    model Substitute

    attributes :direction

    # hardcode the direction for the time being
    def direction
      'in'
    end

  end
end
