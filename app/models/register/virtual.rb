module Register
  class Virtual < Base

    acts_as_commentable

    has_many :scores, as: :scoreable

    belongs_to :meter, class_name: Meter::Virtual, foreign_key: :meter_id

    has_many :formula_parts, dependent: :destroy, foreign_key: 'register_id'
    accepts_nested_attributes_for :formula_parts, reject_if: :all_blank, :allow_destroy => true

    validates :direction, inclusion: { in: self.directions }

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a
    end

    def registers
      Register::Base.where(id: Register::FormulaPart.where(register_id: self.id).select(:operand_id))
    end

    def formula
      result = ""
      self.formula_parts.each do |formula_part|
        result += "#{formula_part.operator} #{formula_part.operand_id} "
      end
      return result
    end

    def get_operands_from_formula
      self.formula_parts.collect(&:operand)
    end

    def data_source
      # give preference to discovergy
      if self.brokers.detect { |b| b.is_a? Broker::Discovergy }
        Buzzn::Discovergy::DataSource::NAME
      else
        Buzzn::Virtual::DataSource::NAME
      end
    end
  end
end
