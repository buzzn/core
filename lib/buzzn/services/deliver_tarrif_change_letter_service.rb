class Services::DeliverTarrifChangeLetterService

  include Import['services.mail_service']

  def initialize(**)
    super
    @logger = Buzzn::Logger.new(self)
  end

  def deliver_tariff_change_letter(localpool, contract, document_id)
    if contract.contact.email.nil?
      deliver_tariff_change_letter_powergiver(localpool, contract, document_id)
    else
      deliver_tariff_change_letter_powertaker(localpool, contract, document_id)
    end
  end

  def deliver_tariff_change_letter_powergiver(localpool, contract, document_id)
    target = Document.find(document_id)

    contact = localpool.contact

    salute = "Hallo #{contact.first_name} #{contact.last_name}"

    if contact.prefix == 'M'
      salute = "Sehr geehrter Herr #{contact.last_name}"
    elsif contact.prefix == 'F'
      salute = "Sehr geehrte Frau #{contact.last_name}"
    end

    message = <<~MSG
      #{salute},

      ihr Strohmnehmer #{contract.contact.first_name}  #{contract.contact.last_name}  hat in unserem System
      leider keine Emailadresse hinterlegt, wir bitten Sie, das angehängte Schreiben zuzustellen.

      Mit freundlichen Grüßen,

      Buzzn Team
    MSG

    mail_service.deliver_later({:from => 'team@buzzn.net',
                                :to => contact.email,
                                :from_person_id => localpool.owner.contact.id,
                                :bcc => 'team@localpool.de',
                                :subject => "Preisanpassungsschreiben Energiegruppe #{localpool.name}",
                                :text => message,
                                :document_id => target.id})
  end

  def deliver_tariff_change_letter_powertaker(localpool, contract, document_id)
    target = Document.find(document_id)

    contact = contract.contact

    salute = "Hallo #{contact.first_name} #{contact.last_name}"

    if contact.prefix == 'M'
      salute = "Sehr geehrter Herr #{contact.last_name}"
    elsif contact.prefix == 'F'
      salute = "Sehr geehrte Frau #{contact.last_name}"
    end

    message = <<~MSG
      #{salute},

      im Auftrag Ihres Stromgebers #{localpool.owner.name} senden wir Ihnen ein Preisanpassungsschreiben für die Lokale Energiegruppe #{localpool.name}.

      Bitte beachten Sie den Anhang.

      Bei Fragen oder sonstigem Feedback stehe ich Ihnen gerne zur Verfügung.

      Energiegeladene Grüße,
    MSG

    mail_service.deliver_later({:from => 'team@buzzn.net',
                                :to => contact.email,
                                :from_person_id => localpool.contact.id,
                                :bcc => 'team@localpool.de',
                                :subject => "Preisanpassung Energiegruppe #{localpool.name}",
                                :text => message,
                                :document_id => target.id})
  end

end
