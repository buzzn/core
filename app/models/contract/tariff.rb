require 'bigdecimal'

module Contract
  class Tariff < ActiveRecord::Base

    self.table_name = :tariffs

    has_and_belongs_to_many :contracts, class_name: 'Contract::Base', association_foreign_key: :contract_id, foreign_key: :tariff_id
    belongs_to :group, class_name: 'Group::Base', foreign_key: :group_id

    scope :in_year, ->(year) {
      where('begin_date <= ?', Date.new(year, 12, 31))
    }

    scope :at, ->(timestamp) do
      where('begin_date <= ?', timestamp)
    end

    scope :current, ->(now = Time.current) { at(now) }

    # permissions helpers
    scope :permitted, ->(uids) { where(group_id: uids) }

    # persisted tariffs are referenced in billings and must not be changed.
    before_update { false }

    def cents_per_day(kwh)
      BigDecimal(kwh, 4) * BigDecimal(self.energyprice_cents_per_kwh, 4) + (BigDecimal(self.baseprice_cents_per_month, 4) * 12) / 365
    end

    def cents_per_day_after_taxes(kwh)
      billing_config = CoreConfig.load(Types::BillingConfig)
      if billing_config.nil?
        raise 'please set Types::BillingConfig'
      end
      cents_per_day(kwh) * billing_config.vat
    end

    def cents_per_days(days, kwh_per_day)
      days * cents_per_day(kwh_per_day)
    end

    def cents_per_days_after_taxes(days, kwh_per_day)
      days * cents_per_day_after_taxes(kwh_per_day)
    end

    def energyprice_cents_per_kwh_before_taxes
      BigDecimal(self.energyprice_cents_per_kwh, 4).round(4)
    end

    def baseprice_cents_per_month_before_taxes
      BigDecimal(self.baseprice_cents_per_month, 4).round(4)
    end

    def energyprice_cents_per_kwh_after_taxes
      billing_config = CoreConfig.load(Types::BillingConfig)
      if billing_config.nil?
        raise 'please set Types::BillingConfig'
      end
      self.energyprice_cents_per_kwh_before_taxes * billing_config.vat
    end

    def baseprice_cents_per_month_after_taxes
      billing_config = CoreConfig.load(Types::BillingConfig)
      if billing_config.nil?
        raise 'please set Types::BillingConfig'
      end
      self.baseprice_cents_per_month_before_taxes * billing_config.vat
    end

  end
end
