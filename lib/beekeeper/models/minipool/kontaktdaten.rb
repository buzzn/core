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
    {
      first_name:          vorname.strip,
      last_name:           nachname.strip,
      title:               title,
      prefix:              prefix,
      phone:               telefon.strip,
      fax:                 fax.strip,
      email:               email.strip,
      preferred_language: :german
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

end
