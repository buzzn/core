# == Schema Information
#
# Table name: minipooldb.adresse
#
#  adress_id    :integer          not null, primary key
#  strasse      :string(100)      not null
#  hausnummer   :string(10)       not null
#  adresszusatz :string(50)       not null
#  plz          :string(6)        not null
#  stadt        :string(30)       not null
#  bundesland   :string(30)       not null
#  gis_lon      :float            not null
#  gis_lat      :float            not null
#  anrede       :string(8)        not null
#

class Beekeeper::Adresse < ActiveRecord::Base
  self.table_name = 'minipooldb.adresse'
end
