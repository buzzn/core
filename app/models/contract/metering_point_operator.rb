require_relative 'localpool'

module Contract
  class MeteringPointOperator < Localpool

    belongs_to :register, class_name: 'Register::Base'

  end
end
