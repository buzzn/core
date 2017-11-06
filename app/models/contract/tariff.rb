module Contract
  class Tariff < ActiveRecord::Base
    self.table_name = :tariffs

    belongs_to :contracts, class_name: Base, foreign_key: :contract_id
    belongs_to :group, class_name: Group::Base, foreign_key: :group_id

    validates :name, presence: true
    validates :begin_date, presence: true
    validates :end_date, presence: false
    # assume all money-data is without taxes!
    validates :energyprice_cents_per_kwh, presence: true, numericality: { only_integer: false, greater_than_or_equal_to: 0 }
    validates :baseprice_cents_per_month, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                  .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) do
      #binding.pry
      where('begin_date <= ?', timestamp)
        .where('end_date > ? OR end_date IS NULL', timestamp + 1.second)
    end
    scope :current, ->(now = Time.current) {where("begin_date < ? AND (end_date > ? OR end_date IS NULL)", now, now)}


    # permissions helpers
    scope :permitted, ->(uuids) { binding.pry; where(group_id: uuids) }
  end
end
