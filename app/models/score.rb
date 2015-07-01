class Score < ActiveRecord::Base
  belongs_to :scoreable, polymorphic: true

  scope :sufficiencies,  -> { where(mode: 'sufficiency') }
  scope :closenesses,    -> { where(mode: 'closeness') }
  scope :autarchies,     -> { where(mode: 'autarchy') }
  scope :fittings,       -> { where(mode: 'fitting') }

  scope :dayly,          -> { where(interval: 'day') }
  scope :monthly,        -> { where(interval: 'month') }
  scope :yearly,         -> { where(interval: 'year') }
end