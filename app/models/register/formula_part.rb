module Register
  class FormulaPart < ActiveRecord::Base
    self.table_name = :formula_parts
    belongs_to :register, class_name: Register::Base, foreign_key: :register_id
    belongs_to :operand, class_name: Register::Base

    scope :additive, -> {where(operator: '+')}
    scope :subtractive, -> {where(operator: '-')}

    validates :operator, inclusion: { in: ['-', '+'] }
    validates :operand, presence: true
    validates :register, presence: true
  end
end
