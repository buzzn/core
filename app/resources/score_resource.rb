class ScoreSerializer < ActiveModel::Serializer

  attributes  :mode,
              :interval,
              :interval_beginning,
              :interval_end,
              :value
end
