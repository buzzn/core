module Group
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes  :name,
                :description,
                :readable

    attributes :updatable, :deletable

    has_many :registers
    has_many :meters
    has_many :managers
    has_many :energy_producers
    has_many :energy_consumers

    # API methods for endpoints

    def scores(interval:, mode: nil, timestamp: Time.current)
      if timestamp > Time.current.beginning_of_day
        timestamp = timestamp - 1.day
      end
      result = object.scores
                 .send("#{interval}ly".to_sym)
                 .containing(timestamp)
      if mode
        result = result.send(mode.to_s.pluralize.to_sym)
      end
      result.readable_by(@current_user).collect { |s| ScoreResource.new(s) }
    end
  end
end
