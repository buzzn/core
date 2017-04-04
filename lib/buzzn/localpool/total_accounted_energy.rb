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
        result[label] = label_result
      end
      return result
    end

    def get_single_by_label(label)
      accounted_energies_hash = get_by_label(label)
      if accounted_energies_hash[label].size != 1
        raise ArgumentError.new("Label #{label} may only occur once in the list.")
      end
      return accounted_energies_hash[label].first
    end

    def sum_and_group_by_label
      result = {}
      all_labels = Buzzn::AccountedEnergy.labels
      energies_by_label = get_by_label(all_labels)
      all_labels.each do |label|
        sum_by_label = 0
        energies_by_label[label].each do |accounted_energy|
          sum_by_label += accounted_energy.value
        end
        result[label] = sum_by_label
      end
      return result
    end
  end
end