# == Schema Information
#
# Table name: buzzndb.bdew_slp_zuordnung
#
#  bdew    :string(20)       not null
#  slp     :string(5)        not null
#  tabelle :string(10)       not null
#

class Beekeeper::Buzzn::BdewSlpZuordnung < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.bdew_slp_zuordnung'
end
