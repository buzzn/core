module Register
  class InputResource < Register::BaseResource
    abstract

    attributes :obis, :mode

  end
end
