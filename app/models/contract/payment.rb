module Contract
  class Payment < ActiveRecord::Base

    belongs_to :contracts, class_name: Base, foreign_key: :contract_id

    validates :begin_date, presence: true
    validates :end_date, presence: false
    # assume all money-data is without taxes!
    validates :price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :cycle, presence: false
    validates :source, presence: false

    # TODO cycle enum ? is cycle a required attribute ?
    # TODO source enum ?

    scope :current, ->(now = Time.current) {where("begin_date < ? AND (end_date > ? OR end_date IS NULL)", now, now)}

    def self.readable_by(*args)
      where(Contract::Base.readable_by(*args).where("payments.contract_id = contracts.id").select(1).limit(1).exists)
    end
  end
end
