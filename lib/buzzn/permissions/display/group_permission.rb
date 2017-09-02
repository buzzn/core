Buzzn::Permission.new(Display::GroupResource) do
  group(:none)
  group(:all, :anonymous)

  create :none
  retrieve :all
  update :none
  delete :none

  mentors do
    retrieve :all
  end

  registers do
    retrieve :all
  end

  scores do
    retrieve :all
  end

  bubbles do
    retrieve :all
  end

  charts do
    retrieve :all
  end
end
