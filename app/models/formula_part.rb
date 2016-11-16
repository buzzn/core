class FormulaPart < ActiveRecord::Base
  belongs_to :register
  belongs_to :operand, class_name: 'Register'

  default_scope { order('created_at ASC') }

  # validates :operand_id, presence: true
  # validates :register_id, presence: true

end
