module Display
  class RegisterResource < Buzzn::Resource::Entity

    model Register::Base

    attributes  :name,
                :label

    def type
      case object
      when Register::Real
        'register_real'
      when Register::Virtual
        'register_virtual'
      else
        raise "unknown register type: #{object.class}"
      end
    end

    def name
      object.meta.name
    end

    def label
      object.meta.attributes['label']
    end

  end
end
