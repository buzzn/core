require 'roda'

class CommonRoda < Roda

  def self.logger
    @logger ||= Buzzn::Logger.new(self)
  end

  def logger
    self.class.logger
  end

  plugin :default_headers,
    'Content-Type' => 'application/json',
    'Content-Security-Policy'=>"default-src 'none'",
    # see https://www.owasp.org/index.php/HTTP_Strict_Transport_Security_Cheat_Sheet
    'Strict-Transport-Security'=>'max-age=31536000; includeSubDomains',
    # standard security headers
    'X-Frame-Options' => 'deny',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block'

end
