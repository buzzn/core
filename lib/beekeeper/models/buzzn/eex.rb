# == Schema Information
#
# Table name: buzzndb.eex
#
#  ideex     :integer
#  datum     :string(16)       not null, primary key
#  timestamp :string(32)
#  h1        :float
#  h2        :float
#  h3        :float
#  h4        :float
#  h5        :float
#  h6        :float
#  h7        :float
#  h8        :float
#  h9        :float
#  h10       :float
#  h11       :float
#  h12       :float
#  h13       :float
#  h14       :float
#  h15       :float
#  h16       :float
#  h17       :float
#  h18       :float
#  h19       :float
#  h20       :float
#  h21       :float
#  h22       :float
#  h23       :float
#  h24       :float
#

class Beekeeper::Buzzn::Eex < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.eex'
end
