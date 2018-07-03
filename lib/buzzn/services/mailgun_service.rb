require_relative '../services'
require_relative '../mail_error'
require 'net/http'

class Services::MailgunService

  def deliver(domain, api_key, message = {})
    form_data = {
      'from' => message[:from],
      'to' => message[:to],
      'subject' => message[:subject],
      'text' => message[:text],
    }
    if message.key?(:bcc) && !message[:bcc].empty?
      form_data['bcc'] = message[:bcc]
    end
    if message.key?(:html) && !message[:html].empty?
      form_data['html'] = message[:html]
    end

    uri = URI.parse("https://api.mailgun.net/v3/#{domain}/messages")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth 'api', api_key
    req.set_form_data(form_data)
    opts = { use_ssl: uri.scheme == 'https'}
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.use_ssl = true
      http.request(req)
    end

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # done
      nil
    else
      raise Buzzn::MailSendError.new res.body
    end
  end

end
