class ScoreResource < Buzzn::BaseResource

  model Score

  attributes  :mode,
              :interval,
              :interval_beginning,
              :interval_end,
              :value
end
