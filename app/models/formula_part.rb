class FormulaPart < ActiveRecord::Base
  belongs_to :metering_point
  belongs_to :operand, class_name: 'MeteringPoint'
end
