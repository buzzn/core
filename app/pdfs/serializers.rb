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
      street: address.street,
      zip: address.zip,
      city: address.city
    }
  end


end