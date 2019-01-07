module Contract
  class ContextedTariff

    ATTRIBUTES = :begin_date, :end_date, :last_date, :tariff
    attr_accessor :begin_date, :end_date, :last_date, :tariff


    def id
      if tariff.nil?
        nil
      else
        tariff.id
      end
    end

    def created_at
      if tariff.nil?
        nil
      else
        tariff.created_at
      end
    end

    def updated_at
      if tariff.nil?
        nil
      else
        tariff.created_at
      end
    end

    def initialize(args)
      args.each do |k,v|
        args.each do |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end
    end

    def attributes
      {}.tap do |hash|
        ATTRIBUTES.each do |a|
          hash[a.to_s] = self.send(a)
        end
      end
    end

  end
end
