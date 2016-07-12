module API
  class Base < Grape::API

    use ::WineBouncer::OAuth2

    rescue_from :all do |e|
      eclass = e.class.to_s
      message = "OAuth error: #{e.to_s}" if eclass.match('WineBouncer::Errors')
      status = case 
        when eclass.match('OAuthUnauthorizedError')
          401 # forbidden
        when eclass.match('OAuthForbiddenError')
          403 # no permissions
        when eclass.match('RecordNotFound'), e.message.match(/unable to find/i).present?
          404 # not found
        else
          (e.respond_to? :status) && e.status || 500
        end
      opts = { error: "#{message || e.message}" }
      opts[:trace] = e.backtrace[0,10] unless Rails.env.production?
      Rack::Response.new(opts.to_json, status, {
          'Content-Type' => "application/json",
          'Access-Control-Allow-Origin' => '*',
          'Access-Control-Request-Method' => '*',
        }).finish
    end

    mount API::V1::Base

  end
end
