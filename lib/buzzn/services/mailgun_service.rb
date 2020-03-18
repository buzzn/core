require_relative '../services'
require_relative '../mail_error'
require 'net/http'
require 'net/http/post/multipart'
require 'stringio'

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
    if message.key?(:reply_to) && !message[:reply_to].empty?
      form_data['h:Reply-To'] = message[:reply_to]
    end
    if message.key?(:html) && !message[:html].empty?
      form_data['html'] = message[:html]
    end

    if message.key?(:document_id) && !message[:document_id].nil?
      document = Document.find(message[:document_id])
      attachment_name = message[:document_name] || document.filename || 'attachment.pdf'
      attachment_mime = message[:document_mime] || document.mime || 'application/pdf'
      io = StringIO.new(document.read)
      form_data['attachment'] = ::UploadIO.new(io, attachment_mime, attachment_name)
    end

    uri = URI.parse("https://api.mailgun.net/v3/#{domain}/messages")

    opts = { use_ssl: uri.scheme == 'https' }

    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      req = Net::HTTP::Post::Multipart.new(uri, form_data)
      req.basic_auth 'api', api_key
      http.request(req)
    end

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # done
      true
    else
      raise Buzzn::MailSendError.new res.body
    end
  end

end
