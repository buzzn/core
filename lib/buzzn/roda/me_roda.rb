require_relative 'base_roda'
class MeRoda < BaseRoda

  include Import.args[:env,
                      'transaction.update_person']

  plugin :rodauth, csrf: false, json: :only do
  
    enable :login, :logout, :change_password, :change_login, :session_expiration, :reset_password, :verify_login_change, :jwt
    
    db Buzzn::DB

    change_login_requires_password? true
    session_expiration_redirect nil
    session_inactivity_timeout 15 # minutes
    max_session_lifetime 86400 # 1 day
    jwt_secret 'testmenow'
    json_response_error_status 401

    set_error_flash do |message|
      k, v = json_response[json_response_field_error_key]
      errors = [{parameter: k, detail: v}]
      response.status = 422
      request.halt [response.status, {'Content-Type': 'application/json'},
                    [{errors: errors}.to_json]]
    end

    create_verify_login_change_email do |login|
      def login.deliver!
        puts self
        self
      end
      login
    end

    create_reset_password_email do
      def reset_password_key_value.deliver!
        puts self
        self
      end
      reset_password_key_value
    end
  end

  route do |r|

    r.rodauth

    if current_user.nil?
      raise Buzzn::PermissionDenied.new(Person, :retrieve, nil)
    end

    # TODO remove `if rodauth.valid_jwt?` once doorkeeper is gone
    rodauth.check_session_expiration if rodauth.valid_jwt?

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
