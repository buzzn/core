module Session

  # used by active-admin as csrf from rails and rack_scrf do not play together 
  class LogoutRoda < Roda

    plugin :rodauth, csrf: false do
  
      enable :logout

      logout_redirect do
        request.params['redirect']
      end

      db Buzzn::DB
    end

    route do |r|
      r.rodauth
    end
  end
end
