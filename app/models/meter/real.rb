module Meter
  class Real < Base

    MUST_HAVE_AT_LEAST_ONE = 'must have at least one register'

    has_many :registers, class_name: Register::Real, foreign_key: :meter_id
    validates_associated :registers

    EASY_METER = 'easy_meter'
    AMPERIX = 'amperix'
    FERRARIS = 'ferraris'
    OTHER = 'other'
    MANUFACTURER_NAMES = [EASY_METER, AMPERIX, FERRARIS, OTHER]

    validates :manufacturer_name, inclusion: {in: MANUFACTURER_NAMES}
    validates :product_name, presence: true
    validates :product_serialnumber, presence: true, uniqueness: true, length: { in: 2..128 }
    validates :direction_number, inclusion: {in: DIRECTION_NUMBERS}
    
    before_destroy do
      # we can't use registers.delete_all here because ActiveRecord translates this into a wrong SQL query.
      Register::Real.where(meter_id: self.id).delete_all
    end

    ['output', 'input'].each do |direction|
      define_method :"#{direction}_register" do
        Register.const_get(direction.capitalize).where(meter_id: self.id).first
      end
    end

    def validate_invariants
      if registers.size == 0
        errors.add(:registers, MUST_HAVE_AT_LEAST_ONE)
      end
      errors.add(:registers, 'must be all none virtual') if registers.detect { |r| r.is_a? Register::Virtual }
    end

    def initialize(attr = {})
      super
      # TODO really needed ? too hacky !
      attr[:registers].each {|r| r.meter = self} if attr.key?(:registers)
    end

    def input_register=(attr)
      registers << Register::Input.new(attr.merge(meter: self))
    end

    def output_register=(attr)
      registers << Register::Output.new(attr.merge(meter: self))
    end

    def direction_number
      if registers.size == 1
        Meter::Base::ONE_WAY_METER
      else
        Meter::Base::TWO_WAY_METER
      end
    end

    # work around AR short-comings

    def valid?(*args)
      if ! super && !errors[:registers].empty?
        registers.each do |r|
          index = 0
          r.errors.each do |key, err|
            errors.add(:"registers.#{index}.#{key}", err)
            index += 1
          end
        end
      end
      errors.empty?
    end

  end
end
