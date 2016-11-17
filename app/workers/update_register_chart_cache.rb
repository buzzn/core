class UpdateRegisterChartCache
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(register_id, timestamp, resolution)
    if Register.exists?(id: register_id)
      registers_hash = Aggregate.sort_registers([Register.find(register_id)])
      aggregate = Aggregate.new(registers_hash)
      aggregate.past(timestamp: timestamp.to_datetime, resolution: resolution, refresh_cache: true)
    end
  end
end
