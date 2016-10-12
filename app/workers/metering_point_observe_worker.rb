class MeteringPointObserveWorker
  include Sidekiq::Worker

  def perform
    MeteringPoint.create_all_observer_activities
  end

end
