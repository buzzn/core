require_relative '../services'
require_relative '../mail_error'
require 'net/http'
require 'net/http/post/multipart'
require 'stringio'

class Services::SmtpService

  def deliver(message = {})
    person_sender = Person.find(message[:from_person_id])

    unless person_sender.email_backend_active?
      person_sender = Person.joins(:roles).where("roles.name = 'BUZZN_OPERATOR' and email_backend_active = true").first
    end

    form_data = {
      'from' => person_sender.email,
      'to' => message[:to],
      'subject' => message[:subject],
      'body' => message[:text],
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

    to_send = Mail.new(form_data)
    res = Net::SMTP.start(person_sender.email_backend_host,
                    person_sender.email_backend_port,
                    person_sender.email_backend_host,
                    person_sender.email_backend_user,
                    person_sender.email_backend_password,
                    :login) do |smtp|
      smtp.send_message(to_send.to_s, person_sender.email, message[:to])
    end

    unless res.success?
      raise Buzzn::MailSendError.new res.string
    end
  end

end
