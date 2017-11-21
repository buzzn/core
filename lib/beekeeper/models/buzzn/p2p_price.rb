# == Schema Information
#
# Table name: buzzndb.p2p_price
#
#  idp2p :integer          not null, primary key
#  datum :string(16)
#  zeit  :time
#  preis :float
#

class Beekeeper::Buzzn::P2pPrice < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.p2p_price'
end
