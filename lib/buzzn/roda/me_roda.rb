require_relative 'base_roda'
module Me
  class Roda < BaseRoda

    include Import.args[:env,
                        'transaction.update_person']

    plugin :rodauth, csrf: false, json: :only do

      enable :login, :logout, :change_password, :change_login, :session_expiration, :reset_password, :verify_login_change, :jwt

      db Buzzn::DB

      change_login_requires_password? true
      session_expiration_redirect nil
      session_inactivity_timeout 15 * 60 # minutes
      max_session_lifetime 86400 # 1 day
      jwt_secret (ENV['JWT_SECRET'] || raise('missing JWT_SECRET in env'))
      json_response_error_status 401

      set_error_flash do |message|
        k, v = json_response[json_response_field_error_key]
        errors = [{parameter: k, detail: v}]
        response.status = 422
        request.halt [response.status, {'Content-Type' => 'application/json'},
                      [{errors: errors}.to_json]]
      end

      create_verify_login_change_email do |login|
        def login.deliver!
          # TODO: send email
          self
        end
        login
      end

      create_reset_password_email do
        def reset_password_key_value.deliver!
          # TODO: send email
          self
        end
        reset_password_key_value
      end
    end

    plugin :run_handler

    route do |r|

      r.run SwaggerRoda, :not_found=>:pass

      r.rodauth

      if current_user.nil?
        raise Buzzn::PermissionDenied.new(Person, :retrieve, nil)
      end

      r.get! 'ping' do
        if rodauth.session[rodauth.session_last_activity_session_key] + rodauth.session_inactivity_timeout < Buzzn::Utils::Chronos.now.to_i
          r.response.status = 401
          {"error" => "This session has expired, please login again." }
        else
          r.response['Content-Type'] = 'text/plain'
          'pong'
        end
      end

      rodauth.check_session_expiration

      person = PersonResource.all(current_user, ContractingPartyPersonResource)
               .retrieve(current_user.person.id)

      r.get! do
        person
      end

      r.patch! do
        update_person.call(r.params, resource: [person])
      end
    end
  end
end
