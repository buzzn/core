module Contract
  class Tariff < ActiveRecord::Base

    self.table_name = :tariffs

    has_and_belongs_to_many :contracts, class_name: 'Contract::Base', association_foreign_key: :contract_id, foreign_key: :tariff_id
    belongs_to :group, class_name: 'Group::Base', foreign_key: :group_id

    scope :in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                  .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) do
      where('begin_date <= ?', timestamp)
        .where('end_date > ? OR end_date IS NULL', timestamp + 1.second)
    end
    scope :current, ->(now = Time.current) {where('begin_date < ? AND (end_date > ? OR end_date IS NULL)', now, now)}

    # permissions helpers
    scope :permitted, ->(uuids) { where(group_id: uuids) }

    # It order to be continuous, a contract's end_date is the same as the start_date of the following contract.
    # This is technically correct but unexpected by humans. That's why we have the last_date, which will show
    # the human-expected last date of the contract.
    def last_date
      end_date && (end_date - 1.day)
    end

  end
end
