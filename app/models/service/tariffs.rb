module Service
  class Tariffs

    class << self

      def data(collection)
        new(collection).data
      end

    end

    def initialize(collection)
      @collection = collection
    end

    # data extracts begin_date, end_date, last_date for all tariffs
    # the result contains a list of entries
    def data
      items = []
      sorted = @collection.sort_by(&:begin_date)
      sorted.each_with_index do |tariff, idx|
        if idx+1 < sorted.size
          following_tariff = sorted[idx+1]
        else
          following_tariff = nil
        end

        item = {
          tariff: tariff
        }.tap do |hash|
          unless following_tariff.nil?
            hash[:end_date]  = following_tariff.begin_date
            hash[:last_date] = following_tariff.begin_date - 1
          end
        end
        items.push(Contract::ContextedTariff.new(item))
      end
      items
    end

  end
end
