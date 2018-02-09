# == Schema Information
#
# Table name: buzzndb.eex_neu
#
#  ideex :integer          not null, primary key
#  datum :string(16)       not null
#  zeit  :time             not null
#  eex   :float            not null
#

class Beekeeper::Buzzn::EexNeu < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.eex_neu'

end
