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

    def managers
      object.managers.readable_by(current_user).collect { |m| UserResource.new(m, current_user: current_user) }
    end

    def meters
      # FIXME broken permissions
      object.meters.collect { |m| Meter::BaseResource.new(m, current_user: @current_user) }
    end

    def registers_old
      # note that anonymized_readable_by does inherit the readable
      # settings of the group
      object.registers
        .anonymized_readable_by(@current_user)
        .by_label(Register::Base::CONSUMPTION,
                  Register::Base::PRODUCTION_PV,
                  Register::Base::PRODUCTION_CHP)
        .collect { |r| Register::BaseResource.new(r, current_user: @current_user) }
    end

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

    def members
      object.members.readable_by(@current_user)
    end
  end
end
