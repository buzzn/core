# == Schema Information
#
# Table name: minipooldb.p2p_price
#
#  idp2p :integer          not null, primary key
#  datum :string(16)
#  zeit  :time
#  preis :float
#

class Beekeeper::P2pPrice < ActiveRecord::Base
  self.table_name = 'minipooldb.p2p_price'
end
