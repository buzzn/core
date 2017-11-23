# == Schema Information
#
# Table name: buzzndb.sn_tarife
#
#  name      :string(25)       not null, primary key
#  gp        :float
#  ap        :float
#  startdate :datetime
#  enddate   :datetime
#  id        :integer
#  at_hall   :integer          default(1)
#

class Beekeeper::Buzzn::SnTarife < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.sn_tarife'
end
