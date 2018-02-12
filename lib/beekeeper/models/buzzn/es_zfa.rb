# == Schema Information
#
# Table name: buzzndb.es_zfa
#
#  marktplatz_id    :integer          not null, primary key
#  name             :string(45)
#  sz_nummer        :string(45)
#  zaehlpunktid     :string(60)
#  zaehler_typ      :string(55)
#  kuendigungsdatum :date
#  timestamp        :string(32)
#  einspeisebeginn  :date
#  einspeiseende    :date
#  wandlerfaktor    :float
#  gis_lon          :float
#  gis_lat          :float
#  nbid             :integer
#  anlagenschlssl   :string(45)
#  zfa              :string(1)
#  mscons_vl        :string(1)
#  login            :string(30)
#  passwd           :string(30)
#  switch_inout     :integer
#  v4qz             :integer
#  energiegewinner  :string(1)
#  wandlerfac_disco :integer
#

class Beekeeper::Buzzn::EsZfa < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.es_zfa'

end
