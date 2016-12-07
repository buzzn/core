class FormulaPart < ActiveRecord::Base
  belongs_to :register, class_name: Register::Base, foreign_key: :register_id
  belongs_to :operand, class_name: Register::Base

  default_scope { order('created_at ASC') }

  # validates :operand_id, presence: true
  # validates :register_id, presence: true

end
