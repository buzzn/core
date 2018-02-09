# == Schema Information
#
# Table name: buzzndb.nb
#
#  idnb                 :integer          not null
#  fullname             :string(100)      not null
#  website              :string(225)
#  telefon              :string(45)
#  email                :string(100)
#  email_abteilung      :string(100)
#  kontakt_vorname      :string(45)
#  kontakt_nachname     :string(45)
#  kontakt_email        :string(145)
#  strasse              :string(45)
#  stadt                :string(45)
#  bundesland           :string(45)
#  plz                  :string(15)
#  land                 :string(45)
#  dav_mail_am          :string(20)
#  bilanzierungsmethode :string(20)
#  fax                  :string(45)
#  sleeve               :string(30)
#  regelzone            :string(45)
#  sep_name             :string(30)
#  datum_arv            :string(45)
#  timestamp            :string(32)
#  edifact_email        :string(45)
#  zertifikat           :string(49)
#

class Beekeeper::Buzzn::Nb < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.nb'

end
