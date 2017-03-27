module Contract
  class PowerTaker < Power

    def self.new(*args)
      super
    end

    belongs_to :register, class_name: Register::Input

    validates :register, presence: true
    validates :old_supplier_name, presence: false
    validates :old_customer_number, presence: false
    validates :old_account_number, presence: false
    validates :begin_date, presence: false

    before_validation :calculate_price

    def validate_invariants
      super
      if old_supplier_name.nil? &&
         old_customer_number.nil? &&
         old_account_number.nil?
        errors.add(:begin_date, IS_MISSING) unless begin_date
      elsif old_supplier_name.nil? ||
         old_customer_number.nil? ||
            old_account_number.nil?
        errors.add(:old_supplier_name, IS_MISSING) unless old_supplier_name
        errors.add(:old_customer_number, IS_MISSING) unless old_customer_number
        errors.add(:old_account_number, IS_MISSING) unless old_account_number
      elsif ! persisted?
        errors.add(:begin_date, NOT_ALLOWED_FOR_OLD_CONTRACT) if begin_date
      end

      if status != WAITING
        errors.add(:begin_date, IS_MISSING) unless begin_date
      end

      unless register.address
        # TODO shall this be a requirement for register anyways ?
        errors.add(:register, 'missing Register Address')
      end
    end

    def calculate_price
      if register && forecast_kwh_pa && register.address &&
         register.meter
        # TODO some validation or errors or something
        prices = Buzzn::Zip2Price.new(forecast_kwh_pa,
                                      register.address.zip,
                                      register.meter.metering_type)
        if price = prices.to_price
          self.tariffs << Contract::Tariff.new(name: 'TODO Tariff',
                                               begin_date: begin_date || Time.current,
                                               energyprice_cents_per_kwh: price.energyprice_cents_per_kilowatt_hour,
                                               baseprice_cents_per_month:price.baseprice_cents_per_month)
          self.payments << Contract::Payment.new(begin_date: begin_date || Time.current,
                                                 cycle: :monthly,
                                                 price_cents: price.total_cents_per_month)
        else
          # TODO some validation or errors or something
        end
      end
    end

  end
end
