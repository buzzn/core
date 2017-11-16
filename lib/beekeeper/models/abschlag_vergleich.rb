# == Schema Information
#
# Table name: minipooldb.abschlag_vergleich
#
#  vertragsnummer     :integer          not null
#  nummernzusatz      :integer          not null
#  abrechnungsjahr    :integer          not null
#  abschlag_berechnet :float
#  abschlag_real      :float
#  id_abschlag        :integer          not null, primary key
#

class Beekeeper::AbschlagVergleich < ActiveRecord::Base
  self.table_name = 'minipooldb.abschlag_vergleich'
end
