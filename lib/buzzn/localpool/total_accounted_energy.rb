module Buzzn::Localpool
  class TotalAccountedEnergy
    attr_reader :localpool_id, :accounted_energies

    def initialize(localpool_id)
      @localpool_id = localpool_id
      @accounted_energies = []
    end

    def add(accounted_energy)
      @accounted_energies << accounted_energy
    end

    def get_by_label(*labels)
      result = {}
      labels.flatten.each do |label|
        label_result = []
        accounted_energies.each do |accounted_energy|
          if accounted_energy.label == label
            label_result << accounted_energy
          end
        end
        result[label.to_sym] = label_result
      end
      return result
    end

    def sum_and_group_by_label
      result = {}
      all_labels = Register::Base.labels + ["consumption_lsn", "consumption_third_party"]
      energies_by_label = get_by_label(all_labels)
      all_labels.each do |label|
        sum_by_label = 0
        energies_by_label[label.to_sym].each do |accounted_energy|
          sum_by_label += accounted_energy.value
        end
        result[label.to_sym] = sum_by_label
      end
      return result
    end
  end
end