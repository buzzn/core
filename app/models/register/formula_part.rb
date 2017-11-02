module Register
  class FormulaPart < ActiveRecord::Base
    self.table_name = :formula_parts
    belongs_to :register, class_name: 'Register::Base', foreign_key: :register_id
    belongs_to :operand, class_name: 'Register::Base'

    enum operator: { plus: '+', minus: '-' }

    scope :operand_meters, -> {
      Meter::Base.where(id: Register::Base.where(id: select(:operand_id)).select(:meter_id))
    }
  end
end
