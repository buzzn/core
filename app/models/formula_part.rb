class FormulaPart < ActiveRecord::Base
  belongs_to :metering_point
  belongs_to :operand, class_name: 'MeteringPoint'

  default_scope { order('created_at ASC') }

  # validates :operand_id, presence: true
  # validates :metering_point_id, presence: true

end
