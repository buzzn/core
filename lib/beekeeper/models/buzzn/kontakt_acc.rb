# coding: utf-8
# == Schema Information
#
# Table name: buzzndb.kontakt_acc
#
#  marktplatz_id   :integer
#  vorname         :string(45)
#  nachname        :string(45)
#  strasse         :string(45)
#  plz             :string(6)
#  stadt           :string(45)
#  bundesland      :string(45)
#  email           :string(45)
#  telefon         :string(45)
#  typ             :string(45)
#  status          :string(45)
#  produkt         :string(25)
#  geschlecht      :string(45)
#  anrede          :string(45)
#  titel           :string(45)
#  briefanrede     :string(45)
#  email2          :string(45)
#  bestätigung     :string(45)
#  hausnummer      :string(6)
#  account_selbst  :string(6)
#  timestamp       :string(32)
#  fibunr          :integer          not null, primary key
#  photo_vorhanden :string(1)
#

class Beekeeper::Buzzn::KontaktAcc < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.kontakt_acc'


  def converted_attributes
    {
      first_name:   vorname,
      last_name:    nachname,
      email:        email,
      phone:        telefon,
      prefix:       prefix,
      title:        title,
    }
  end

  private

  ANREDE_TO_PREFIX_MAP = {
    ""         => nil,
    "Herr"     => 'M',
    "Herrn"    => 'M',
    "Frau"     => 'F'
  }

  TITEL_TO_TITLE_MAP = {
    ""         => nil,
  }

  def prefix
    ANREDE_TO_PREFIX_MAP.fetch(anrede)
  end

  def title
    TITEL_TO_TITLE_MAP.fetch(titel)
  end
end
