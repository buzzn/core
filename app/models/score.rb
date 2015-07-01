class Score < ActiveRecord::Base
  belongs_to :scoreable, polymorphic: true

  scope :sufficiencies,  -> { where(mode: 'sufficiency') }
  scope :closenesses,    -> { where(mode: 'closeness') }
  scope :autarchies,     -> { where(mode: 'autarchy') }
  scope :fittings,       -> { where(mode: 'fitting') }
end