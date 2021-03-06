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

    def kind
      if label.production?
        :production
      elsif label.consumption?
        :consumption
      elsif label.grid_consumption?
        :grid_consumption
      elsif label.demarcation?
        :demarcation
      elsif label.grid_feeding?
        :grid_feeding
      else
        :system
      end
    end

    [:consumption, :production, :grid_consumption, :grid_feeding, :system, :demarcation].each do |method|
      define_method("#{method}?") do
        kind == method
      end
    end

    before_save :check_offline_values
    before_create :check_offline_values

    private

    def check_offline_values
      if self.observer_enabled.nil?
        self.observer_enabled = false
      end
      if self.observer_offline_monitoring.nil?
        self.observer_offline_monitoring = false
      end
    end

  end
end
