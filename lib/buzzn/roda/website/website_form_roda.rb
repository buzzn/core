require_relative '../base_roda'

module Website
  class WebsiteFormRoda < BaseRoda

    include Import.args[:env,
                        'transactions.website.website_form.create',
                        'transactions.website.website_form.update_internal']

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

      r.get! do
        website_forms
      end

      r.on :id do |id|
        website_form = website_forms.retrieve(id)

        r.get! do
          website_form
        end

        r.patch! do
          update_internal.(resource: website_form, params: r.params)
        end

      end

    end

  end
end
