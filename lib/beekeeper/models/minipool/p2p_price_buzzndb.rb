# == Schema Information
#
# Table name: minipooldb.p2p_price_buzzndb
#
#  idp2p :integer          not null, primary key
#  datum :string(16)
#  zeit  :time
#  preis :float
#

class Beekeeper::Minipool::P2pPriceBuzzndb < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.p2p_price_buzzndb'
end
