class Display::ScoreResource < Buzzn::Resource::Base

  model Score

  attributes  :mode,
              :interval,
              :interval_beginning,
              :interval_end,
              :value
end
