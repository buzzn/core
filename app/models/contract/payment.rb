module Contract
  class Payment < ActiveRecord::Base

    belongs_to :contracts, class_name: Base, foreign_key: :contract_id

    validates :begin_date, presence: true
    validates :end_date, presence: false
    # assume all money-data is without taxes!
    validates :price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :cycle, presence: false
    validates :source, presence: false

    scope :in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                  .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) { where('begin_date <= ?', timestamp)
                                  .where('end_date >= ? OR end_date IS NULL', timestamp + 1.second) }

    # TODO cycle enum ? is cycle a required attribute ?
    # TODO source enum ?

    def self.readable_by(*args)
      where(Contract::Base.readable_by(*args).where("payments.contract_id = contracts.id").select(1).limit(1).exists)
    end
  end
end
