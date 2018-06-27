require 'buzzn/roda/base_roda'

class Website::TestWebsiteFormRoda < BaseRoda

  plugin :run_handler

  route do |r|
    r.run Me::Roda, :not_found=>:pass
    r.on 'website/website-forms' do
      r.run Website::WebsiteFormRoda
    end
  end

end
