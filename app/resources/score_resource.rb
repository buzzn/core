class ScoreResource < JSONAPI::Resource
  attributes  :mode,
              :interval,
              :interval_beginning,
              :interval_end,
              :value
end
