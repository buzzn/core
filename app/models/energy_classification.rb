class EnergyClassification < ActiveRecord::Base

  MUST_BE_HUNDRED_PERCENT_TOGETHER = 'must be 100.0 % together'

  belongs_to :organization

  validates :tariff_name, presence: false, length: { in: 4..54 }
  validates :nuclear_ratio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :coal_ratio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :gas_ratio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :other_fossiles_ratio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :renewables_eeg_ratio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :other_renewables_ratio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :co2_emission_gramm_per_kWh, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :nuclear_waste_miligramm_per_kWh, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :end_date, presence: false

  validate :validate_invariants

  scope :by_tariff, -> (tariff) { where(tariff_name: tariff) }
  scope :valid_at, ->  (timestamp) do
    timestamp = case timestamp
                when DateTime
                  timestamp.to_date
                when Time
                  timestamp.to_date
                when Date
                  timestamp
                when Fixnum
                  Time.at(timestamp).to_date
                else
                  raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                end
    where('end_date >= ? OR end_date IS NULL', timestamp)
  end

  def validate_invariants
    unless (nuclear_ratio + coal_ratio + gas_ratio + other_fossiles_ratio + renewables_eeg_ratio + other_renewables_ratio).round == 100
      errors.add(:nuclear_ratio, MUST_BE_HUNDRED_PERCENT_TOGETHER )
      errors.add(:coal_ratio, MUST_BE_HUNDRED_PERCENT_TOGETHER )
      errors.add(:gas_ratio, MUST_BE_HUNDRED_PERCENT_TOGETHER )
      errors.add(:other_fossiles_ratio, MUST_BE_HUNDRED_PERCENT_TOGETHER )
      errors.add(:renewables_eeg_ratio, MUST_BE_HUNDRED_PERCENT_TOGETHER )
      errors.add(:other_renewables_ratio, MUST_BE_HUNDRED_PERCENT_TOGETHER )
    end
  end

end