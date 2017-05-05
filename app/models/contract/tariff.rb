module Contract
  class Tariff < ActiveRecord::Base

    belongs_to :contracts, class_name: Base, foreign_key: :contract_id

    validates :name, presence: true
    validates :begin_date, presence: true
    validates :end_date, presence: false
    # assume all money-data is without taxes!
    validates :energyprice_cents_per_kwh, presence: true, numericality: { only_integer: false, greater_than_or_equal_to: 0 }
    validates :baseprice_cents_per_month, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :current, ->(now = Time.current) {where("begin_date < ? AND (end_date > ? OR end_date IS NULL)", now, now)}

    def self.readable_by(*args)
      # inherit from contract
      where(Contract::Base.readable_by(*args).where("tariffs.contract_id = contracts.id").select(1).limit(1).exists)
    end
  end
end
