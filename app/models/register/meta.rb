module Register
  class Meta < ActiveRecord::Base

    self.table_name = :register_meta

    class Label < String

      ['production', 'consumption', 'demarcation', 'grid'].each do |method|
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

    belongs_to :register, class_name: 'Real', foreign_key: :register_id

  end
end
