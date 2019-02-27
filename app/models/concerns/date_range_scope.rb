module DateRangeScope

  extend ActiveSupport::Concern

  included do |base|
    scope :in_date_range, ->(date_range) {
      # When joining tables, the begin and end date columns can exist on more than one table.
      # So we need to specify which table we mean to avoid 'PG::AmbiguousColumn' exceptions.
      begin_date_col = "#{base.table_name}.begin_date"
      end_date_col   = "#{base.table_name}.end_date"
      where("#{end_date_col} IS NULL OR #{end_date_col} > ?", date_range.first) # fetch items running or ended in the period
        .where("#{begin_date_col} < ?", date_range.last) # don't fetch items starting after the period
        .order(:begin_date) # ensure chronological order to ease testing
    }
    scope :end_before, ->(time) {
      end_date_col = "#{base.table_name}.end_date"
      where("#{end_date_col} IS NULL OR #{end_date_col} < ?", time).order(:begin_date)
    }
    scope :end_before_or_same, ->(time) {
      end_date_col = "#{base.table_name}.end_date"
      where("#{end_date_col} IS NULL OR #{end_date_col} <= ?", time).order(:begin_date)
    }
    scope :end_after_or_same,  ->(time) {
      end_date_col = "#{base.table_name}.end_date"
      where("#{end_date_col} IS NULL OR #{end_date_col} >= ?", time).order(:begin_date)
    }

    # overlap a date_range and the date_range
    # of the entity
    def minmax_date_range(date_range)
      first = date_range.first
      last = date_range.last
      if self.end_date && self.end_date < date_range.last
        last = self.end_date
      end
      if self.begin_date > date_range.first
        first = self.begin_date
      end
      first..last
    end
  end

end
