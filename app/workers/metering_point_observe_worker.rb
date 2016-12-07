class RegisterObserveWorker
  include Sidekiq::Worker

  def perform
    Register::Base.create_all_observer_activities
  end

end
