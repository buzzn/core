# frozen-string-literal: true
require_relative '../filterable'

module Register
  class Base < ActiveRecord::Base

    self.table_name = :registers

    include Import.active_record['services.current_power']

    include Filterable

    belongs_to :meter, class_name: 'Meter::Base', foreign_key: :meter_id

    has_one :group, through: :meter
    has_many :readings, class_name: 'Reading::Single', foreign_key: 'register_id'
    has_many :billing_items, class_name: 'BillingItem', foreign_key: 'register_id'
    has_many :billings, through: :billing_items

    belongs_to :meta, class_name: 'Meta', foreign_key: :register_meta_id

    has_many :contracts, through: :meta

    scope :real,    -> { where(type: Register::Reak) }
    scope :virtual, -> { where(type: Register::Virtual) }

    scope :consumption_production, -> do
      by_labels(*Register::Meta.labels.select { |label, _| label.production? || label.consumption? }.values)
    end
    scope :production_consumption, -> { consumption_production }

    scope :production, -> do
      by_labels(*Register::Meta.labels.select { |label, _| label.production? }.values)
    end

    scope :grid_consumption_production, -> do
      by_labels(*Register::Meta.labels.select { |label, _| label.production? || label.consumption? | label.grid? }.values)
    end
    scope :grid_production_consumption, -> { grid_consumption_production }

    scope :by_group, ->(group) { group ? self.where(group: group.id) : self.where(group: nil) }

    scope :by_labels, ->(*labels) do
      if (Register::Meta.labels.values & labels).sort != labels.sort
        raise ArgumentError.new("#{labels.inspect} needs to be subset of #{Register::Base.labels.values}")
      end
      self.joins(:meta).where('register_meta.label in (?)', labels)
    end

    # permissions helpers

    # FIXME broken
    scope :permitted, ->(uids) { joins(:contracts).where('contracts.id': uids) }

    def reading_at(date)
      readings.find_by(date: date)
    end

    def obis
      if meta&.label&.consumption? || meta&.label&.grid_consumption?
        '1-1:1.8.0'
      elsif meta&.label&.production? || meta&.label&.grid_feeding?
        '1-1:2.8.0'
      else
        nil
      end
    end

    def kind
      meta&.kind
    end

    [:consumption, :production, :demarcation, :grid_consumption, :grid_feeding, :system].each do |method|
      define_method("#{method}?") do
        kind == method
      end
    end

    def installed_at
      self.readings.installed.order(:date).first
    end

    def decomissioned?
      !self.readings.decomissioned.order(:date).last.nil?
    end

    def decomissioned_at
      self.readings.decomissioned.order(:date).last
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

    # HACK for nested invariant

    def meta_for_invariant
      meta.nil? ? nil : Schemas::Support::ActiveRecordValidator.new(meta)
    end

  end
end
