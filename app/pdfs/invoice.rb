require 'buzzn/pdf_generator'

module Buzzn::Pdfs
  class Invoice < Buzzn::PdfGenerator

    def initialize(billing)
      super
      @billing = billing
    end

    protected

    def build_struct
      {
        contractor: build_contractor,
        powertaker: build_powertaker,
        localpool: build_localpool,
        billing: build_billing,
        contract: { number: contract.full_contract_number }
      }
    end

    private

    def contract
      @contract ||= @billing.contract
    end

    def contractor
      @contractor ||= contract.contractor
    end

    def powertaker
      @powertaker ||= contract.customer
    end

    def contractor_address
      @caddress ||= contractor.address
    end

    def name(person_or_organization)
      case person_or_organization
      when Person
        person_or_organization.first_name + ' ' + person_or_organization.last_name
      when Organization
        person_or_organization.name
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def contact(person_or_organization)
      case person_or_organization
      when Person
        person_or_organization
      when Organization
        person_or_organization.contact
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def addressing(person_or_organization)
      case person_or_organization
      when Person
        prefix = case person_or_organization.prefix
                 when 'F'
                   'Sehr geehrte Frau'
                 when 'M'
                   'Sehr geehrter Herr'
                 else
                   'Hallo'
                 end
        "#{prefix} #{person_or_organization.title} #{person_or_organization.last_name}"
      when Organization
        'Sehr geehrte Damen und Herren'
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def build_contractor
      data = {
        name: name(contractor),
        contact: name(contact(contractor)),
      }
      %i(phone fax email).each do |field|
        data[field] = contractor.send(field)
      end
      contractor.address.tap do |address|
        %i(street zip city).each do |field|
          data[field] = address.send(field)
        end
      end
      contract.contractor_bank_account.tap do |account|
        %i(iban bic bank_name).each do |field|
          data[field] = account.send(field)
        end
      end
      data
    end

    def build_powertaker
      data = {
        addressing: addressing(powertaker),
      }
      contact(powertaker).tap do |contact|
        %i(title first_name last_name email).each do |field|
          data[field] = contact.send(field)
        end
      end
      powertaker.address.tap do |address|
        %i(street zip city).each do |field|
          data[field] = address.send(field)
        end
      end
      data
    end

    def build_billing
      {
        date: @billing.last_date,
        number: @billing.invoice_number
      }
    end

    def build_localpool
      {
        name: contract.localpool.name
      }
    end

  end
end
