# == Schema Information
#
# Table name: buzzndb.account_new
#
#  marktplatz_id           :integer
#  fibunr                  :integer          not null, primary key
#  gesellschafts_name      :string(100)
#  strasse                 :string(45)
#  hausnummer              :string(45)
#  plz                     :string(6)
#  stadt                   :string(25)
#  bundesland              :string(40)
#  telefon                 :string(20)
#  fax                     :string(45)
#  email                   :string(45)
#  privat1_gbr2_weg3_else4 :string(20)
#  comment                 :text
#  timestamp               :string(32)
#  vertreter               :string(100)
#

class Beekeeper::Buzzn::AccountNew < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.account_new'
end
