class Meter < ActiveRecord::Base
  include Authority::Abilities

  has_many :registers, dependent: :destroy
  accepts_nested_attributes_for :registers, :reject_if => :all_blank, :allow_destroy => true

  has_many :equipments

  # normalize_attribute :uid, with: [:strip]

  def self.manufacturers
    %w{
      ferraris
      smart_meter
    }
  end

end