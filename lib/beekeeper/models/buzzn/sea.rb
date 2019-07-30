# == Schema Information
#
# Table name: buzzndb.sea
#
#  marktplatz_id   :integer          not null, primary key
#  hersteller      :string(45)
#  technologie     :string(45)
#  typ             :string(45)
#  primaer_energie :string(45)
#  leistung        :float
#  inbetriebname   :string(45)
#  ende_kwk_foe    :string(45)
#  co2_gperkwh     :float
#  gesetzgebung    :string(45)
#  datum_erzeugt   :datetime
#

class Beekeeper::Buzzn::Sea < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.sea'

end
