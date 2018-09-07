def build_address_json(address)
  json = address.as_json
  json.delete('created_at')
  json.delete('updated_at')
  json.delete('id')
  json['country'] = 'DE'
  json.delete_if { |k, v| v.nil? }
  json
end

def build_person_json(person, address_json)
  json = person.as_json
  json.delete('created_at')
  json.delete('updated_at')
  json.delete_if { |k, v| v.nil? }
  json.delete('image')
  json.delete('address_id')
  json['preferred_language'] = 'de'
  json['prefix'] = 'M'
  unless address_json.nil?
    json['address'] = address_json
  end
  json
end

def build_organization_json(organization:, address_json: nil, contact_json: nil, legal_representation_json: nil)
  json = organization.as_json
  json.delete('created_at')
  json.delete('updated_at')
  json.delete('id')
  json.delete('slug')
  json.delete_if { |k, v| v.nil? || (k.is_a?(String) && k.ends_with?('_id')) }
  unless address_json.nil?
    json['address'] = address_json
  end
  unless contact_json.nil?
    json['contact'] = contact_json
  end
  unless legal_representation_json.nil?
    json['legal_representation'] = legal_representation_json
  end
  json
end

