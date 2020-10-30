class Services::DeliverTarrifChangeLetterService

  include Import['services.mail_service']

  def initialize(**)
    super
    @logger = Buzzn::Logger.new(self)
  end

  def deliver_tariff_change_letter(localpool, contract, document_id)
    target = Document.find(document_id)

    sender = if localpool.owner.is_a?(Organization::GeneralResource)
               localpool.owner.contact
             else
               localpool.owner
             end

    contact = contract.contact

    salute = "Hallo #{contact.first_name} #{contact.last_name}"

    if contact.prefix == 'M'
      salute = "Sehr geehrter Herr #{contact.last_name}"
    elsif contact.prefix == 'F'
      salute = "Sehr geehrte Frau #{contact.last_name}"
    end

    message = <<~MSG
      #{salute},

      mit dieser Email erhalten Sie das Preisanpassungsschreiben der Energiegruppe #{localpool.name}.

      Mit freundlichen Grüßen,
      #{sender.first_name} #{sender.name}
      #{sender.email_backend_signature}
    MSG

    mail_service.deliver_later({:from => 'team@buzzn.net',
                                :to => contact.email,
                                :from_person_id => localpool.owner.contact.id,
                                :bcc => 'team@localpool.de',
                                :subject => "Preisanpassungsschreiben Energiegruppe #{localpool.name}",
                                :text => message,
                                :document_id => target.id})
  end

end
