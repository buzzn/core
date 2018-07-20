require_relative 'real'

module Register
  class Input < Real

    # before_create do
    #   self.direction = Base.directions[:input]
    # end

    def obis
      '1-1:1.8.0'
    end

  end
end
