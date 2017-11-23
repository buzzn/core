# == Schema Information
#
# Table name: buzzndb.fahrplan_dates
#
#  id           :integer          not null, primary key
#  datefpsoll   :datetime
#  dateprogbase :datetime
#  timestamp    :string(32)
#

class Beekeeper::Buzzn::FahrplanDates < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.fahrplan_dates'
end
