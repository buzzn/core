require_relative 'power'

module Contract
  class PowerGiver < Power

    belongs_to :register, class_name: 'Register::Output'

  end
end
