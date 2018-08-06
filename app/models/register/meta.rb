module Register
  class Meta < ActiveRecord::Base

    self.table_name = :register_meta

    class Label < String

      ['production', 'consumption', 'demarcation', 'grid', 'grid_consumption', 'grid_feeding'].each do |method|
        define_method "#{method}?" do
          self.to_s.start_with?(method)
        end
      end

    end

    enum label: %i(consumption consumption_common
      demarcation_pv demarcation_chp demarcation_wind demarcation_water
      production_pv production_chp production_wind production_water
      grid_consumption grid_feeding
      grid_consumption_corrected grid_feeding_corrected
      other
    ).each_with_object({}) { |item, map| map[Label.new(item.to_s)] = item.to_s.upcase }

    has_many :registers, class_name: 'Base', foreign_key: :register_meta_id

    has_many :contracts, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base', foreign_key: :register_meta_id
    has_many :billings, through: :contracts

    def register
      registers.last
    end

    belongs_to :market_location, class_name: 'MarketLocation', foreign_key: :market_location_id

    def contracts_in_date_range(date_range)
      contracts.in_date_range(date_range)
    end

    def billings_in_date_range(date_range)
      billings.in_date_range(date_range)
    end

  end
end
