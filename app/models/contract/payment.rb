require_relative 'base'

module Contract
  class Payment < ActiveRecord::Base

    enum cycle: {
           monthly: 'monthly',
           yearly: 'yearly',
           once: 'once'
       }

    belongs_to :contract, class_name: 'Contract::Base', foreign_key: :contract_id

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
                  when Integer
                    Time.at(timestamp)
                  else
                    raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                  end
        where('begin_date <= ?', timestamp)
          .where('end_date >= ? OR end_date IS NULL', timestamp + 1.second)
    end

    scope :current, ->(now = Time.current) {where('begin_date < ? AND (end_date > ? OR end_date IS NULL)', now, now)}

  end
end
