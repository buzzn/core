module Register
  class Input < Register::Base

    def initialize(*args)
      super
      @mode = :in
    end

    def obis
      '1-0:1.8.0'
    end

  end
end
