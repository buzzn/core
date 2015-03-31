class Dashboard < ActiveRecord::Base
  belongs_to :user

  has_and_belongs_to_many :metering_points

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :slug_name,
      :id
    ]
  end


  private

    def slug_name
      SecureRandom.uuid
    end
end
