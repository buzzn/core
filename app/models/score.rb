class Score < ActiveRecord::Base
  include Authority::Abilities
  belongs_to :scoreable, polymorphic: true

  # TODO default scope is always an extra constraint on every query, i.e.
  #      get rid of it
  default_scope { order('interval_beginning ASC') }

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

  scope :readable_by, ->(user) do
    # TODO remove hack with correcting sql, i.e. replace Group.readable_by(user)
    # with Group.readable_by_query(user)
    # i.e. with Register
    sqls = [
      Group.readable_by(user).where("groups.id=scores.scoreable_id").project(1).exists.to_sql.sub('"groups".*,', ''),
      Register::Base.readable_by(user).where("registers.id=scores.scoreable_id").project(1).exists.to_sql.sub('"registers".*,', '')
    ]
    where(sqls.join(' OR '))
  end

  validate :validate_invariants

  def validate_invariants
    errors.add(:scoreable, "must have superclass ActiveRecord::Base: #{self.scoreable_type}") unless self.scoreable_type.constantize.superclass == ActiveRecord::Base
  end
end
