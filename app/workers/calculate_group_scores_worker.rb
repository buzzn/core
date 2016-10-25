class CalculateGroupScoresWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(containing_timestamp)
    Group.all.each do |group|
      # be failsafe so we do run over all the groups
      group.calculate_scores(containing_timestamp) rescue nil
    end
  end
end
