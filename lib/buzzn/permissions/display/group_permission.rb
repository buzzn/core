Display::GroupResource::Permission = Buzzn::Permission.new(Display::GroupResource) do
  # define groups of roles
  group(:none)
  group(:all, Role::ANONYMOUS)

  # top level CRUD permissions
  create :none
  retrieve :all
  update :none
  delete :none

  # nested method and its CRUD permissions, missing ones means no permissions
  mentors do
    retrieve :all
  end

  registers do
    retrieve :all
  end

  bubbles do
    retrieve :all
  end

  charts do
    retrieve :all
  end

  scores do
    retrieve :all
  end
end
