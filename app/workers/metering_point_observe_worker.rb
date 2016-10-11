class MeteringPointObserveWorker
  include Sidekiq::Worker

  def perform
    MeteringPoint.where("observe = ? OR observe_offline = ?", true, true).each do |metering_point|
      metering_point.create_observer_activity
    end
  end

end
