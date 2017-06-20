class GroupResource < Buzzn::Resource::Entity
  include Import.reader['service.current_power',
                        'service.charts']

  abstract

  model Group::Base

  attributes  :name,
              :slug,
              :description

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
    all(permissions.scores, result, ScoreResource)
  end
    
  def bubbles
    current_power.for_each_register_in_group(self)
  end

  def charts(duration:, timestamp: nil)
    @charts.for_group(self, Buzzn::Interval.create(duration, timestamp))
  end

  def type
    case object
    when Group::Tribe
      'group_tribe'
    when Group::Localpool
      'group_localpool'
    else
      raise "unknown group type: #{object.class}"
    end
  end
end
