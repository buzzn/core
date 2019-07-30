class TestAdminLocalpoolRoda < BaseRoda

  plugin :run_handler

  route do |r|
    r.run Me::Roda, :not_found=>:pass
    r.run Admin::Roda
  end

end
