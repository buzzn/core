# == Schema Information
#
# Table name: buzzndb.markers
#
#  id            :integer          not null
#  marktplatz_id :integer          not null
#  name          :string(60)       not null
#  address       :string(80)       not null
#  lat           :float            not null
#  lng           :float            not null
#  type          :string(30)       not null
#  link_to_pic   :string(200)
#  link_email    :string(200)
#  text          :string(200)
#  technique     :string(100)
#  timestamp     :string(32)
#

class Beekeeper::Buzzn::Markers < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.markers'

end
