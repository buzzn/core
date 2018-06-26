require 'buzzn/roda/base_roda'

class TestWebsiteFormRoda < BaseRoda

  plugin :run_handler

  route do |r|
    r.run Me::Roda, :not_found=>:pass
    r.on 'website-forms' do
      r.run WebsiteFormRoda::Roda
    end
  end

end
