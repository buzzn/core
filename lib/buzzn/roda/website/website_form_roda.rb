require_relative '../base_roda'

module Website
  class WebsiteFormRoda < BaseRoda

    include Import.args[:env, 'transactions.website_form.create']

    plugin :run_handler

    route do |r|

      website_forms = WebsiteFormResource.all(current_user)

      r.post! do
        create.(resource: website_forms, params: r.params)
      end

      rodauth.check_session_expiration

      if current_user.nil?
        r.response.status = 401
        r.halt
      end

      forms = WebsiteFormResource.all(current_user)

      r.get! do
        forms
      end

    end

  end
end
