module Buzzn
  module Utils
    class Chronos
      class << self
        private :new

        def now
          Time.now.utc
        end

        def yesterday
          today - 1.day
        end

        def today
          n = now
          Date.new(n.year, n.month, n.day)
        end

        # This method returns the timespan between two dates in months while considering half months
        # input params:
        #   date_1: The first Date to compare
        #   date_2: The second Date to compare
        # returns:
        #   months between two dates, e.g. 11 or 11.5 or 12
        def timespan_in_months(date_1, date_2)
          if date_1 > date_2
            date_2_temp = date_1.clone
            date_1 = date_2.clone
            date_2 = date_2_temp
          end
          days = date_2.day - date_1.day
          months = date_2.month - date_1.month
          years = date_2.year - date_1.year
          half_rounded = 0
          factor = days < 0 ? -1 : 1
          days = factor * days
          if days > 19
            half_rounded = factor * 1
          elsif days >= 9
            half_rounded = factor * 0.5
          end
          years * 12 + months + half_rounded
        end
      end
    end
  end
end
        
