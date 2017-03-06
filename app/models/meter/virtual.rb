module Meter
  class Virtual < Base

    def after_create_callback(user, obj)
      obj.register.class.after_create_callback(user, obj.register)
    end

    def after_destroy_callback(user, obj)
      obj.register.class.after_destroy_callback(user, obj.register)
    end

    has_one :register, class_name: Register::Virtual, dependent: :destroy, foreign_key: :meter_id
    validates_associated :register

    validates :register, presence: true
    validates :manufacturer_product_name, presence: false
    validates :manufacturer_product_serialnumber, presence: false, uniqueness: true, allow_nil: true, length: { in: 2..128 }


    def validate_invariants
      [:manufacturer_name, :smart, :image].each do |name|
        error.add(name, 'not allowed') if send(:name).nil?
      end
    end

    def initialize(attr = {})
      attr[:register] = Register::Virtual.new(attr[:register] || {}) if attr && attr[:register].is_a?(Hash)
      super
      register.meter = self if register
    end

    # work around AR short-comings

    def valid?(*args)
      if ! super && !errors[:register].empty? && register
        register.errors.each do |key, err|
          errors.add(:"register.#{key}", err)
        end
      end
      errors.empty?
    end
  end
end
