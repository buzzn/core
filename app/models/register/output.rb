module Register
  class Output < Register::Base

    def initialize(*args)
      super
    end

    def obis
      '1-0:2.8.0'
    end

  end
end
