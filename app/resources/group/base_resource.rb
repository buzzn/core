module Group
  class MinimalBaseResource < Buzzn::BaseResource

    abstract

    model Group::Base

    attributes  :name,
                :description,
                :readable

    attributes :updatable, :deletable

    has_many :registers
    has_many :meters
    has_many :managers
    has_many :energy_producers
    has_many :energy_consumers

    def meters
      # FIXME broken permissions
      object.meters
    end

    def registers
      # note that anonymized_readable_by does inherit the readable
      # settings of the group
      object.registers
        .anonymized_readable_by(@current_user)
        .by_label(Register::Base::CONSUMPTION,
                  Register::Base::PRODUCTION_PV,
                  Register::Base::PRODUCTION_CHP)
    end

    # API methods for endpoints

    def scores(params)
      interval = params[:interval]
      timestamp = params[:timestamp]
      mode = params[:mode]
      if timestamp > Time.current.beginning_of_day
        timestamp = timestamp - 1.day
      end
      result = object.scores.send("#{interval}ly".to_sym).at(timestamp)
      if mode
        result = result.send(mode.to_s.pluralize.to_sym)
      end
      result.readable_by(@current_user)
    end

    def members
      object.members.readable_by(@current_user)
    end

    def comments
      object.comment_threads.readable_by(@current_user)
    end
  end

  # we do not want all infos in collections
  class BaseResource < MinimalBaseResource

    attributes   :big_tumb,
                 :md_img

    def md_img
      object.image.md.url
    end

    def big_tumb
      object.image.big_tumb.url
    end

  end

  # TODO get rid of the need of having a Serializer class
  class BaseSerializer < MinimalBaseResource
    def self.new(*args)
      super
    end
  end
end
