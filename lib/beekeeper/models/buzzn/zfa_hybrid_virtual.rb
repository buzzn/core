# == Schema Information
#
# Table name: buzzndb.zfa_hybrid_virtual
#
#  uegz          :string(40)       not null, primary key
#  einsp_pv_z    :string(40)
#  einsp_bhkw_z  :string(40)
#  erz_pv_z      :string(40)
#  erz_bhkw_z    :string(40)
#  nbid          :integer
#  wandlerfaktor :integer
#

class Beekeeper::Buzzn::ZfaHybridVirtual < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.zfa_hybrid_virtual'
end
