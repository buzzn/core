class Meter < ActiveRecord::Base
  include Authority::Abilities

  validates :manufacturer_product_serialnumber, :registers, presence: true

  has_many :registers, dependent: :destroy
  accepts_nested_attributes_for :registers, :reject_if => :all_blank, :allow_destroy => true

  has_many :equipments
  accepts_nested_attributes_for :equipments, :reject_if => :all_blank, :allow_destroy => true

  mount_uploader :image, PictureUploader

  def self.manufacturers
    %w{
      ferraris
      smart_meter
    }
  end

end