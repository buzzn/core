module Register
  class Virtual < Register::Base

    acts_as_commentable

    has_many :scores, as: :scoreable

    belongs_to :meter, class_name: Meter::Virtual, foreign_key: :meter_id

    has_many :formula_parts, dependent: :destroy, foreign_key: 'register_id'
    accepts_nested_attributes_for :formula_parts, reject_if: :all_blank, :allow_destroy => true

    validates :direction, inclusion: { in: self.directions }

    def registers
      Register::Base.where(id: Register::FormulaPart.where(register_id: self.id).select(:operand_id))
    end

    def smart?
      self.formula_parts.any? do |formula_part|
        formula_part.operand.smart?
      end
    end
       
    def smart=(*args)
      raise 'not available'
    end

    def formula
      result = ""
      self.formula_parts.each do |formula_part|
        result += "#{formula_part.operator} #{formula_part.operand_id} "
      end
      return result
    end

    def get_operands_from_formula
      #TODO empty array possible, i.e. remove the 'unless'
      unless self.formula_parts.empty?
        self.formula_parts.collect(&:operand)
      end
    end
  end
end
