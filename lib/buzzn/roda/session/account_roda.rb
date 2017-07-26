module Session
  class AccountRoda < Roda

    plugin :rodauth do
  
      enable :login, :logout, :change_password, :session_expiration#,:reset_password, :create_account

      prefix '.'

      login_redirect do
        request.params['redirect'] || '.'
      end

      logout_redirect do
        request.params['redirect'] || 'login'
      end

      login_additional_form_tags do
        "<input type='hidden' name='redirect' value='#{request.params['redirect']}' />" if request.params['redirect']
      end

      change_password_redirect '.'

      session_expiration_redirect 'login'
      session_inactivity_timeout 15 # minutes
      max_session_lifetime 86400 # 1 day

      db Buzzn::DB
    end

    route do |r|

      r.rodauth

      rodauth.check_session_expiration

      r.root do
        view 'index'
      end

    end
  end
end
