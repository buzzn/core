# == Schema Information
#
# Table name: buzzndb.sep_slp_names
#
#  sep_slp_id   :integer          not null, primary key
#  sep_slp_name :string(70)
#

class Beekeeper::Buzzn::SepSlpNames < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.sep_slp_names'
end
