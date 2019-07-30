require_relative 'real'

module Register
  class Input < Real

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a.direction = Base.directions[:input]
      a
    end

    # before_create do
    #   self.direction = Base.directions[:input]
    # end

    def obis
      '1-0:1.8.0'
    end

  end
end
