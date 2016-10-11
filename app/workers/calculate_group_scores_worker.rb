class CalculateGroupScoresWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(containing_timestamp)
    Group.all.each do |group|
      group.calculate_scores(containing_timestamp)
    end
  end
end
