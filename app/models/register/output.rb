module Register
  class Output < Real

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a.direction = Base.directions[:output]
      a
    end

    # before_create do
    #   self.direction = Base.directions[:output]
    # end

    def obis
      '1-0:2.8.0'
    end

  end
end
