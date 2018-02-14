# frozen-string-literal: true
require_relative '../filterable'

module Register
  class Base < ActiveRecord::Base

    self.table_name = :registers

    include Import.active_record['services.current_power']

    include Filterable

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

    enum direction: { input: 'in', output: 'out' }

    has_many :contracts, class_name: 'Contract::Base', dependent: :destroy, foreign_key: 'register_id'
    belongs_to :market_location
    has_many :devices, foreign_key: 'register_id'
    has_many :readings, class_name: 'Reading::Single', foreign_key: 'register_id'

    scope :real,    -> { where(type: [Register::Input, Register::Output]) }
    scope :virtual, -> { where(type: Register::Virtual) }

    scope :consumption_production, -> do
      by_labels(*Register::Base.labels.select { |label, _| label.production? || label.consumption? }.values)
    end

    scope :production_consumption, -> do
      consumption_production
    end

    scope :production, -> do
      by_labels(*Register::Base.labels.select { |label, _| label.production? }.values)
    end

    scope :by_group, -> (group) do
      group ? self.where(group: group.id) : self.where(group: nil)
    end

    scope :by_labels, -> (*labels) do
      if (Register::Base.labels.values & labels).sort != labels.sort
        raise ArgumentError.new("#{labels.inspect} needs to be subset of #{Register::Base.labels.values}")
      end
      self.where('label in (?)', labels)
    end

    # permissions helpers

    scope :permitted, ->(uids) { joins(:contracts).where('contracts.id': uids) }

    def name
      if market_location
        market_location.name
      elsif persisted?
        "Register #{id}"
      else
        'Register (not persisted)'
      end
    end

    def name=(new_name)
      # FIXME: remove and adapt all tests not to set the register name.
    end

    def data_source
      Buzzn::MissingDataSource.name
    end

    def broker
      meter.broker
    end

    # FIXME: it would be best to raise an exception here (and even define this class as abstract as well)
    # but raising here causes lots of test & code to fail.
    def obis
      nil
    end

    def low_load_ability
      false
    end

    def pre_decimal_position
      6
    end

    def post_decimal_position
      1
    end

  end
end
