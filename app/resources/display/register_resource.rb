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
        raise 'unknown group type'
      end
    end

    def self.to_resource(user, roles, permissions, instance, clazz = nil)
      super(user, roles, permissions, instance, clazz || self)
    end
  end
end
