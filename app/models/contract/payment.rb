module Contract
  class Payment < ActiveRecord::Base

    #cycle constants
    MONTHLY = 'monthly'
    YEARLY = 'yearly'
    ONCE = 'once'
    enum cycle: {
           monthly: MONTHLY,
           yearly: YEARLY,
           once: ONCE
       }
    CYCLES = [MONTHLY, YEARLY, ONCE].freeze

    # FIXME: a payment belongs to ONE contract, so the association should also be named contract
    belongs_to :contracts, class_name: Base, foreign_key: :contract_id
    # FIXME: remove these when association is fixed
    alias contract contracts
    alias contract= contracts=

    validates :begin_date, presence: true
    validates :end_date, presence: false
    # assume all money-data is without taxes!
    validates :price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                  .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) do
      timestamp = case timestamp
                  when DateTime
                    timestamp.to_time
                  when Time
                    timestamp
                  when Date
                    timestamp.to_time
                  when Fixnum
                    Time.at(timestamp)
                  else
                    raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                  end
        where('begin_date <= ?', timestamp)
          .where('end_date >= ? OR end_date IS NULL', timestamp + 1.second)
    end

    scope :current, ->(now = Time.current) {where("begin_date < ? AND (end_date > ? OR end_date IS NULL)", now, now)}

  end
end
