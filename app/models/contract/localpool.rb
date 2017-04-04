module Contract
  class Localpool < Base
    # HACK: needed intermediate class to have `readable_by` working with
    #       the type constraints supplied by AR
  end
end
