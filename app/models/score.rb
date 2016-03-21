class Score < ActiveRecord::Base
  belongs_to :scoreable, polymorphic: true

  default_scope { order('interval_beginning ASC') }

  scope :sufficiencies,  -> { where(mode: 'sufficiency') }
  scope :closenesses,    -> { where(mode: 'closeness') }
  scope :autarchies,     -> { where(mode: 'autarchy') }
  scope :fittings,       -> { where(mode: 'fitting') }

  scope :dayly,          -> { where(interval: 'day') }
  scope :monthly,        -> { where(interval: 'month') }
  scope :yearly,         -> { where(interval: 'year') }

  scope :at, lambda {|containing_timestamp|
    time = Time.at(containing_timestamp.to_i/1000).in_time_zone
    self.where(["interval_beginning <= ?", time]).where(["interval_end >= ?", time])
  }

end