class FormulaPart < ActiveRecord::Base
  belongs_to :metering_point
  belongs_to :operand, class_name: 'MeteringPoint'

  validates :operand_id, presence: true
  validates :metering_point_id, presence: true

end
