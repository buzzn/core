module Register
  class Output < Real

    acts_as_commentable

    has_many :scores, as: :scoreable

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a.direction = OUT
      a
    end

    def obis
      '1-0:2.8.0'
    end

  end
end
