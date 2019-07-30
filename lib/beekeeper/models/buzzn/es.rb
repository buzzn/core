# == Schema Information
#
# Table name: buzzndb.es
#
#  marktplatz_id      :integer          not null, primary key
#  wo_selbe0_andere1  :string(60)
#  name               :string(45)
#  strasse            :string(45)
#  hausnummer         :string(45)
#  zusatz             :string(45)
#  plz                :string(20)
#  stadt              :string(45)
#  bundesland         :string(40)
#  land               :string(45)
#  email              :string(45)
#  sz_nummer          :string(45)
#  zaehlpunktid       :string(60)
#  messart            :string(45)
#  zaehler_hersteller :string(45)
#  zaehler_typ        :string(55)
#  gebaeudetyp        :string(45)
#  kuendigungsdatum   :date
#  timestamp          :string(32)
#  einspeisebeginn    :date
#  einspeiseende      :date
#  kommentar          :text
#  kundennummer_nb    :string(35)
#  vertragskonto_nb   :string(45)
#  wandlerfaktor      :float
#  gis_lon            :float
#  gis_lat            :float
#  fibunr             :integer
#  reservepool        :boolean
#  nbid               :integer
#  sepid              :integer
#  status             :string(45)
#  schonbeisws        :string(1)
#  anlagenschlssl     :string(45)
#  zfa                :string(1)
#  msb                :string(40)
#  is_lcp             :string(1)
#  cascade_formula    :string(60)
#  msb_id             :string(10)       not null
#

class Beekeeper::Buzzn::Es < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.es'

end
