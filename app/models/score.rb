class Score < ActiveRecord::Base
  include Authority::Abilities
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
    # i.e. with MeteringPoint
    sqls = [
      Group.readable_by(user).where("groups.id=scores.scoreable_id AND scores.scoreable_type='Group'").project(1).exists.to_sql.sub('"groups".*,', ''),
      MeteringPoint.readable_by(user).where("metering_points.id=scores.scoreable_id AND scores.scoreable_type='MeteringPoint'").project(1).exists.to_sql.sub('"metering_points".*,', '')
    ]
    where(sqls.join(' OR '))
  end
end
