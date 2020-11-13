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

    if person_sender.nil?
      raise Buzzn::ValidationError.new({person: ['has no active backend']}, person_sender)
    end

    form_data = {
      to: message[:to],
      subject: message[:subject],
      bcc: message[:bcc],
      body: message[:text] + person_sender.email_backend_signature.gsub('##', "\n"),
      from: "#{person_sender.name} <#{person_sender.email}>"
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

    to_send = Mail.new(form_data)
    if message.key?(:document_id) && !message[:document_id].nil?
      document = Document.find(message[:document_id])
      to_send.add_file(:filename => message[:document_name] || document.filename || 'attachment.pdf',
                       :content => document.read)
    end

    conection = Net::SMTP.new(person_sender.email_backend_host, person_sender.email_backend_port)

    if person_sender.email_backend_encryption == 'SSL/TLS'
      conection.enable_ssl
    elsif person_sender.email_backend_encryption == 'STARTTLS'
      conection.enable_starttls
    end

    res = conection.start(person_sender.email_backend_host,
                          person_sender.email_backend_user,
                          person_sender.email_backend_password, :login) do |smtp|
      smtp.send_message(to_send.to_s, person_sender.email, [message[:to]].concat(to_send.bcc))
    end

    unless res.success?
      raise Buzzn::MailSendError.new res.string
    end
  end

end
