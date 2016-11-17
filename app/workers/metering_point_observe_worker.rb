class RegisterObserveWorker
  include Sidekiq::Worker

  def perform
    Register.create_all_observer_activities
  end

end
