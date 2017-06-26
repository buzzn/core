class Score < ActiveRecord::Base
  belongs_to :scoreable, polymorphic: true

  scope :sufficiencies,  -> { where(mode: 'sufficiency') }
  scope :closenesses,    -> { where(mode: 'closeness') }
  scope :autarchies,     -> { where(mode: 'autarchy') }
  scope :fittings,       -> { where(mode: 'fitting') }

  scope :dayly,          -> { where(interval: 'day') }
  scope :monthly,        -> { where(interval: 'month') }
  scope :yearly,         -> { where(interval: 'year') }

  scope :at, lambda {|containing_timestamp|
    if containing_timestamp.is_a?(DateTime)
      time = containing_timestamp
    else
      time = Time.at(containing_timestamp.to_i/1000).in_time_zone
    end
    self.where(["interval_beginning <= ?", time]).where(["interval_end >= ?", time])
  }

  scope :containing, lambda {|time|
    self.where(["interval_beginning <= ?", time]).where(["interval_end >= ?", time])
  }

  validate :validate_invariants

  def validate_invariants
    errors.add(:scoreable, "must have superclass ActiveRecord::Base: #{self.scoreable_type}") unless self.scoreable_type.constantize.superclass == ActiveRecord::Base
  end
end
