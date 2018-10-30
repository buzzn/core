require_relative '../website_form'
require 'buzzn/utils/helpers'

class Transactions::Website::WebsiteForm::Create < Transactions::Base

  validate :schema
  add :create_website_form, with: :'operations.action.create_item'
  tee :send_notification
  map :done

  include Import[
            'services.mail_service',
            'config.powertaker_v1_from',
            'config.powertaker_v1_bcc',
          ]

  def schema
    Schemas::Transactions::Website::WebsiteForm::Create
  end

  def create_website_form(params:, resource:)
    WebsiteFormResource.new(
      *super(resource, params)
    )
  end

  def send_notification(create_website_form:, **)
    symbolized = Buzzn::Utils::Helpers.symbolize_keys_recursive(create_website_form.form_content)

    case create_website_form.form_name
    when 'powertaker_v1'
      schema = Schemas::Transactions::Website::WebsiteForm::PowertakerV1
      generator = Mail::PowerTaker
      subject = 'Dein Stromauftrag bei buzzn'
      bcc = powertaker_v1_bcc
      from = powertaker_v1_from
      email = symbolized&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:email) ||
              symbolized&.[](:personalInfo)&.[](:person)&.[](:email)
    else
      schema = nil
      generator = nil
      subject = nil
      bcc = nil
      from = nil
      email = nil
    end

    if !schema.nil? && !generator.nil?
      result = schema.call(symbolized)
      if result.success?
        mail = generator.new(symbolized)
        text = mail.to_text
        if email && text
          mail_service.deliver_later(:from => from, :to => email, :subject => subject, :text => text, :bcc => bcc)
        end
      end
    end
  end

  def done(create_website_form:, **)
    create_website_form
  end

end
