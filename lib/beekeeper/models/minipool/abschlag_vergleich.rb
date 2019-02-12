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

class Beekeeper::Minipool::AbschlagVergleich < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.abschlag_vergleich'

  def converted_attributes
    {
      contract_number: vertragsnummer,
      contract_number_addition: nummernzusatz,
      year: abrechnungsjahr,
      paid: abschlag_real,
    }
  end

end
