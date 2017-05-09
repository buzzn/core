class BillingCycle < ActiveRecord::Base
  include Authority::Abilities
  include Buzzn::GuardedCrud

  has_many :billings, dependent: :destroy

  belongs_to :localpool, class_name: 'Group::Localpool'

  validates :begin_date, presence: true
  validates :end_date, presence: true
  validates :name, presence: true
  validates :localpool_id, presence: true

  def self.readable_by_query(user)
    billing_cycle = BillingCycle.arel_table
    localpool = Group::Base.arel_table

    # workaround to produce false always
    return billing_cycle[:id].eq(billing_cycle[:id]).not if user.nil?

    # assume all IDs are globally unique
    sqls = [
      User.roles_query(user, admin: nil),
      User.roles_query(user, manager: billing_cycle[:localpool_id])
    ]
    sqls = sqls.collect{|s| s.project(1).exists}
    sqls[0].or(sqls[1])
  end

  scope :readable_by, -> (user) do
    where(readable_by_query(user))
  end

  def status
    all_stati = billings.collect(&:status).uniq
    if all_stati.include?(Billing::OPEN)
      Billing::OPEN
    elsif all_stati.include?(Billing::CALCULATED)
      Billing::CALCULATED
    elsif all_stati.include?(Billing::DELIVERED)
      Billing::DELIVERED
    elsif all_stati.include?(Billing::SETTLED)
      Billing::SETTLED
    else
      Billing::CLOSED
    end
  end
end