class ScoreResource < Buzzn::BaseResource

  model Score

  attributes  :mode,
              :interval,
              :interval_beginning,
              :interval_end,
              :value
end

# TODO get rid of the need of having a Serializer class
class ScoreSerializer < ScoreResource
end
