# == Schema Information
#
# Table name: buzzndb.sg_aspi_spec
#
#  marktplatz_id       :integer          not null, primary key
#  transaktionsentgeld :float
#  datetime            :datetime
#  timestamp           :string(32)
#  comment             :text
#

class Beekeeper::Buzzn::SgAspiSpec < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.sg_aspi_spec'

end
