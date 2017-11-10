class CalculateGroupScoresWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(timestamp)
    Group::Base.all.each do |group|
      # be failsafe so we do run over all the groups
      Buzzn::ScoreCalculator.new(group, Time.parse(timestamp)).calculate_all_scores rescue nil
    end
  end
end
