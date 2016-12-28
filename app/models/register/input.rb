module Register
  class Input < Real

    acts_as_commentable

    has_many :scores, as: :scoreable

    def obis
      '1-0:1.8.0'
    end

  end
end
