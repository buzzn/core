require_relative 'base_roda'
class MeRoda < BaseRoda

  include Import.args[:env,
                      'transaction.update_person']

  plugin :rodauth, csrf: false, json: :only do
  
    enable :login, :logout, :change_password, :change_login, :session_expiration, :reset_password, :verify_login_change
    
    db Buzzn::DB

    [:after_login,
     :after_logout,
     :after_change_password,
     :after_change_login,
     :after_verify_login_change,
     :after_reset_password_request,
     :after_reset_password].each do |method|
      send method do
        request.halt [205, {}, []]
      end
    end

    change_login_requires_password? true
    session_expiration_redirect nil
    session_inactivity_timeout 15 # minutes
    max_session_lifetime 86400 # 1 day

    login_required do
      request.halt [401, {}, []]
    end

    set_redirect_error_flash do |message|
      # coming from reset-password-request with unknown login param
      request.halt [401, {}, []]
    end

    set_error_flash do |message|
      errors = @field_errors.collect do |k, v|
        {parameter: k, detail: v}
      end
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
