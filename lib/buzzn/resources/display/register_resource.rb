module Display
  class RegisterResource < Buzzn::Resource::Entity

    model Register::Base

    attributes  :direction,
                :name,
                :label

    def type
      case object
      when Register::Real
        'register_real'
      when Register::Virtual
        'register_virtual'
      else
        raise "unknown group type: #{object.class}"
      end
    end
  end
end
