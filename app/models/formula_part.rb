class FormulaPart < ActiveRecord::Base
  belongs_to :user
  belongs_to :operand, class_name: 'MeteringPoint'
end
