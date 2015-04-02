class Dashboard < ActiveRecord::Base
  belongs_to :user

  has_and_belongs_to_many :metering_points

  after_create :create_dashboard_metering_points

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :slug_name,
      :id
    ]
  end

  def dashboard_metering_points
    self.metering_points.where(is_dashboard_metering_point: true)
  end


  private

    def slug_name
      SecureRandom.uuid
    end

    def create_dashboard_metering_points
      3.times do
        self.metering_points << MeteringPoint.create(is_dashboard_metering_point: true, virtual: true)
      end
    end
end
