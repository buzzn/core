# == Schema Information
#
# Table name: minipooldb.kontaktdaten
#
#  kontaktdaten_id :integer          not null, primary key
#  anrede          :string(20)       not null
#  titel           :string(20)       not null
#  geschlecht      :string(10)       not null
#  vorname         :string(40)       not null
#  nachname        :string(100)      not null
#  firma           :string(40)       not null
#  vertretung      :integer          not null
#  telefon         :string(20)       not null
#  fax             :string(20)       not null
#  email           :string(80)       not null
#  mobil           :string(20)       not null
#  rechtsform      :string(20)       not null
#

class Beekeeper::Minipool::Kontaktdaten < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.kontaktdaten'

  def converted_attributes
    person? ? person_attributes : organization_attributes
  end

  # These are not labeled "Privatperson" but actually are.
  ADDITIONAL_PERSONS = [1201]

  # These are labeled "Privatperson" but actually aren't.
  PERSONS_ACTUALLY_ORGANIZATIONS = [418, 419, 420, 421, 782, 783, 513, 837, 838]

  def person?
    is_additional_person           = ADDITIONAL_PERSONS.include?(kontaktdaten_id)
    rechtsform_private             = rechtsform.strip == "Privatperson"
    is_organization                = PERSONS_ACTUALLY_ORGANIZATIONS.include?(kontaktdaten_id)
    is_additional_person || (rechtsform_private && !is_organization)
  end

  private

  def person_attributes
    {
      first_name:          vorname.strip,
      last_name:           nachname.strip,
      title:               title,
      prefix:              prefix,
      phone:               telefon.strip,
      fax:                 fax.strip,
      email:               email.strip.downcase,
      preferred_language:  :german
    }
  end

  def organization_attributes
    {
      name:  organization_name,
      email: email.strip.downcase,
      phone: telefon.strip,
      fax:   fax.strip,
      # these are fields our Organization model has, which we don't import, yet.
      # address,
      # legal_representation,
      # contact
    }
  end

  PREFIX_MAP = {
    'Herr' => 'M',
    'Frau' => 'F'
  }

  def prefix
    PREFIX_MAP[anrede]
  end

  # title is an enum in the core app DB.
  # also, we only have the values 'Dr.' and '' in beekeeper.
  def title
    titel =~ /\s*Dr\.\s*/ ? 'Dr.' : nil
  end

  # This fixes the rows 418-421 which need to be handled as organizations, but firma is "" there.
  # Fortunately the organization name is in the "nachname" column there.
  def organization_name
    firma.present? ? firma : nachname
  end
end
