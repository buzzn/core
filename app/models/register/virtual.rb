require_relative 'base'

module Register
  class Virtual < Base

    belongs_to :meter, class_name: 'Meter::Virtual', foreign_key: :meter_id

    has_many :formula_parts, dependent: :destroy, foreign_key: 'register_id'

    def formula
      result = ''
      self.formula_parts.each do |formula_part|
        result += "#{formula_part.operator} #{formula_part.operand_id} "
      end
      return result
    end

    def data_source
      # give preference to discovergy
      if self.broker.is_a? Broker::Discovergy
        Buzzn::Discovergy::DataSource::NAME
      else
        Buzzn::Virtual::DataSource::NAME
      end
    end

  end
end
