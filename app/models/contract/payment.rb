require_relative 'base'

module Contract
  class Payment < ActiveRecord::Base

    enum cycle: {
           monthly: 'monthly',
           yearly: 'yearly',
       }

    scope :in_year, ->(year) { where(begin_date: Date.new(year-1, 12, 31)...Date.new(year, 12, 31)) }

    scope :at, ->(timestamp) do
      timestamp = case timestamp
                  when DateTime
                    timestamp.to_time
                  when Time
                    timestamp
                  when Date
                    timestamp.to_time
                  when Integer
                    Time.at(timestamp)
                  else
                    raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                  end
        where('begin_date <= ?', timestamp).order(:begin_date).last
    end

    scope :current, ->(now = Time.current) { at(now) }

    belongs_to :tariff, class_name: 'Contract::Tariff', foreign_key: :tariff_id
    belongs_to :contract, class_name: 'Contract::Base', foreign_key: :contract_id
    has_many :billings, foreign_key: :adjusted_payment_id

  end
end
