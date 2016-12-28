module Register
  class Output < Real

    acts_as_commentable

    has_many :scores, as: :scoreable

    def obis
      '1-0:2.8.0'
    end

  end
end
