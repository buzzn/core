class TestWebsiteFormRoda < BaseRoda

  plugin :run_handler

  route do |r|
    r.run Me::Roda, :not_found=>:pass
    r.run WebsiteForm::Roda
  end

end
