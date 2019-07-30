# == Schema Information
#
# Table name: buzzndb.indizes
#
#  ididx          :integer          not null, primary key
#  datum          :datetime
#  idxsolar       :float
#  idxwindonshore :float
#  idxsteuerbar   :float
#  idxkwk         :float
#

class Beekeeper::Buzzn::Indizes < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.indizes'

end
