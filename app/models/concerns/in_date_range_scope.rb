module InDateRangeScope

  extend ActiveSupport::Concern

  included do |base|
    scope :in_date_range, lambda do |date_range|
      # When joining tables, the begin and end date columns can exist on more than one table.
      # So we need to specify which table we mean to avoid 'PG::AmbiguousColumn' exceptions.
      begin_date_col = "#{base.table_name}.begin_date"
      end_date_col   = "#{base.table_name}.end_date"
      where("#{end_date_col} IS NULL OR #{end_date_col} > ?", date_range.first) # fetch items running or ended in the period
        .where("#{begin_date_col} < ?", date_range.last) # don't fetch items starting after the period
        .order(:begin_date) # ensure chronological order to ease testing
    end
  end

end
