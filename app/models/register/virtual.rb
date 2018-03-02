require_relative 'base'

module Register
  class Virtual < Base

    belongs_to :meter, class_name: 'Meter::Virtual', foreign_key: :meter_id

    has_many :formula_parts, dependent: :destroy, foreign_key: 'register_id'

    def formula
      result = ''
      self.formula_parts.each do |formula_part|
        result += "#{formula_part.operator} #{formula_part.operand_id} "
      end
      return result
    end

    def datasource
      raise 'not implemented'
    end

  end
end
