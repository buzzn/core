require_relative '../services'
require_relative '../mail_error'
require 'erb'

class Services::MailStdoutService

  def initialize
    super
    @logger = Buzzn::Logger.new(self)
  end

  def deliver(message = {})
    erb=%{

From: <%= from %>
To: <%= to %>
<% unless bcc.nil? || bcc.length == 0 %>
BCC: <%= bcc %>
<% end %>
----------------------

Subject: <%= subject %>

-----------------------

<%= text %>

<% unless html.nil? || html.length == 0 %>
<%= html %>
<% end %>
}
    @logger.info(ERB.new(erb).result(OpenStruct.new(message).instance_eval { binding }))
  end

end
