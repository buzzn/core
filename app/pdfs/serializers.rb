module Pdf::Serializers

  def partner_name(customer)
    names = [name(legal_partner(customer))]
    if customer == Organization::GeneralResource || customer == Organization::Base
      if !customer.additional_legal_representation.nil? || !customer.additional_legal_representation.empty?
        names += customer.additional_legal_representation.split('$#$').map {|x| x.strip }
      end
    end
    if names.size > 1
      names[0..names.size-2].join(', ') + " und #{names[-1]}"
    else
      names[0]
    end
  end

  def name(person_or_organization)
    case person_or_organization
    when PersonResource
      person_or_organization.first_name + ' ' + person_or_organization.last_name
    when Person
      person_or_organization.first_name + ' ' + person_or_organization.last_name
    when Organization::GeneralResource
      person_or_organization.name
    when Organization::Base
      person_or_organization.name
    else
      raise "can not handle #{person_or_organization.class}"
    end
  end

  def org_name(person_or_organization)
    case person_or_organization
    when Organization::GeneralResource
      person_or_organization.name
    when Organization::Base
      person_or_organization.name
    else
      ''
    end
  end

  def legal_partner(person_or_organization)
    case person_or_organization
    when PersonResource
      person_or_organization
    when Person
      person_or_organization
    when Organization::GeneralResource
      person_or_organization.legal_representation
    when Organization::Base
      person_or_organization.legal_representation
    else
      raise "can not handle #{person_or_organization.class}"
    end
  end

  def contact_person(person_or_organization)
    case person_or_organization
    when PersonResource
      person_or_organization
    when Person
      person_or_organization
    when Organization::GeneralResource
      person_or_organization.contact
    when Organization::Base
      person_or_organization.contact
    else
      raise "can not handle #{person_or_organization.class}"
    end
  end

  def build_address(address)
    {
      addition: (!address.addition.nil? && !address.addition.empty?) ? address.addition : '-',
      street: address.street,
      zip: address.zip,
      city: address.city
    }
  end

  def build_powergiver(powergiver)
    build_partner(powergiver)
  end

  def build_powertaker(powertaker)
    build_partner(powertaker)
  end

  def build_bank_account(bank_account)
    {
      holder: bank_account.holder,
      iban: bank_account.iban,
      bic: bank_account.bic,
      bank_name: bank_account.bank_name,
    }
  end

  def build_partner(partner)
    {
      name: name(partner),
      org_name: org_name(partner),
      shortname: partner.name,

      partner_name: partner_name(partner),
      contact: build_contact(partner),
      address: build_address(partner.address),
      fax: partner.fax,
      phone: partner.phone,
      email: partner.email
    }.tap do |h|
      h[:contact_email] = (!h[:contact].nil? && h[:contact][:email].nil?) ? h[:email] : h[:contact][:email]
    end
  end

  def build_contact(customer)
    {
      name: name(contact_person(customer)),
      title: contact_person(customer).title,
      first_name: contact_person(customer).first_name,
      last_name: contact_person(customer).last_name,

      addressing_full: addressing_full(customer),
      addressing: addressing(customer),

      fax: contact_person(customer).fax,
      phone: contact_person(customer).phone,
      email: contact_person(customer).email,

      address: build_address(contact_person(customer).address)
    }
  end

  def addressing(person_or_organization)
    case person_or_organization
    when Person
      case person_or_organization.prefix
      when 'female'
        'Frau'
      when 'male'
        'Herr'
      else
        'Sonstige'
      end
    when Organization
    when Organization::General
      if person_or_organization.contact
        addressing(person_or_organization.contact)
      else
        'Organisation'
      end
    else
      raise "can not handle #{person_or_organization.class}"
    end
  end

  def addressing_full(person_or_organization)
    case person_or_organization
    when Person
      prefix = case person_or_organization.prefix
               when 'female'
                 'Sehr geehrte Frau'
               when 'male'
                 'Sehr geehrter Herr'
               else
                 'Hallo'
               end
      if prefix == 'Hallo'
        "#{prefix} #{person_or_organization.first_name} #{person_or_organization.last_name}"
      else
        "#{prefix} #{person_or_organization.title} #{person_or_organization.last_name}"
      end
    when Organization
    when Organization::General
      if person_or_organization.contact
        addressing(person_or_organization.contact)
      else
        'Sehr geehrte Damen und Herren'
      end
    else
      raise "can not handle #{person_or_organization.class}"
    end
  end

  def german_div(cents, prec: 2)
    # round cents to precision after divison
    onesr = (cents/100).round(prec)
    sprintf("%s,%s", onesr.truncate, (onesr.remainder(1)*10).abs.to_s.delete('.').ljust(prec, '0').first(prec))
  end

  def german_date(date)
    date.strftime('%d.%m.%Y')
  end

  def some_or(obj, thing)
    (!obj.nil? && !obj.empty?) ? obj : thing
  end

end
