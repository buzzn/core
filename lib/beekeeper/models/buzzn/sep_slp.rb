# == Schema Information
#
# Table name: buzzndb.sep_slp
#
#  idsep                :integer          not null, primary key
#  datum                :string(16)
#  zeit                 :time
#  slp_bayern           :float
#  sep_treuchtlingen    :float
#  sep_vnmrmn           :float
#  sep_eonmitte         :float
#  sep_eonhanse         :float
#  sep_enwag_bhkw       :float            not null
#  g0_nieders           :float            not null
#  sep_weilburg         :float            not null
#  sep_jahresband       :float            not null
#  lsw_wolfsburg        :float            not null
#  sep_neustadtaisch    :float            not null
#  sep_ovag             :float            not null
#  sep_goerlitz         :float            not null
#  sepfeldstrwedel_2012 :float            not null
#  sep_eichstaett       :float            not null
#  sep_pv               :float            not null
#  windsep_ewe_2013     :float            not null
#  sep_solar_profil     :float            not null
#

class Beekeeper::Buzzn::SepSlp < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.sep_slp'
end
