# == Schema Information
#
# Table name: minipooldb.nb_sync
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
#

class Beekeeper::NbSync < ActiveRecord::Base
  self.table_name = 'minipooldb.nb_sync'
end
