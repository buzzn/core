module Meter
  class Real < Base

    MUST_HAVE_AT_LEAST_ONE = 'must have at least one register'

    mount_uploader :image, PictureUploader

    has_many :equipments

    has_many :registers, class_name: Register::Real, foreign_key: :meter_id

    def self.manufacturer_names
      ['easy_meter', 'amperix', 'ferraris', 'other']
    end

    validates :manufacturer_name, inclusion: {in: manufacturer_names}
    validates :manufacturer_product_name, presence: true
    validates :manufacturer_product_serialnumber, presence: true, uniqueness: true, length: { in: 2..128 }
    validates :image, presence: false

    before_destroy do
      registers.delete_all
    end

    ['output', 'input'].each do |direction|
      define_method :"#{direction}_register" do
        Register.const_get(direction.capitalize).where(meter_id: self.id).first
      end
    end

    def validate_invariants
      if registers.size == 0
        errors.add(:registers, MUST_HAVE_AT_LEAST_ONE)
      else
        errors.add(:registers, 'must be all none virtual') if registers.detect { |r| r.is_a? Register::Virtual }
      end
    end
    
    def initialize(attr = {})
      super
      attr[:registers].each {|r| r.meter = self} if attr.key?(:registers)
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

    def input_register=(attr)
      registers << Register::Input.new(attr.merge(meter: self))
    end

    def output_register=(attr)
      registers << Register::Output.new(attr.merge(meter: self))
    end
  end
end
