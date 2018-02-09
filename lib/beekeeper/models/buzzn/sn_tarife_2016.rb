# == Schema Information
#
# Table name: buzzndb.sn_tarife_2016
#
#  name      :string(25)
#  gp        :float
#  ap        :float
#  startdate :datetime
#  enddate   :datetime
#  id        :integer          not null, primary key
#  at_hall   :integer          default(1)
#

class Beekeeper::Buzzn::SnTarife2016 < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.sn_tarife_2016'

end
