class Price < ActiveRecord::Base

  belongs_to :localpool, class_name: Group::Localpool

  validates :begin_date, presence: true
  validates :name, presence: true, length: { in: 2..40 }
  validates :localpool_id, presence: true
  # assume all money-data is without taxes!
  validates :energyprice_cents_per_kilowatt_hour, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :baseprice_cents_per_month, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates_uniqueness_of :begin_date, scope: [:localpool_id], message: 'already available for given localpool'

  scope :valid_at, ->  (timestamp) do
    timestamp = case timestamp
                when DateTime
                  timestamp.to_date
                when Time
                  timestamp.to_date
                when Date
                  timestamp
                when Fixnum
                  Time.at(timestamp).to_date
                else
                  raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                end
    where('begin_date <= ?', timestamp).order('begin_date DESC').limit(1)
  end

  # permissions helpers

  scope :restricted, ->(uuids) { where(localpool_id: uuids) }
end
