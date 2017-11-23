# == Schema Information
#
# Table name: buzzndb.sep_eeg_monthly
#
#  iq      :integer          not null, primary key
#  month1  :float
#  month2  :float
#  month3  :float
#  month4  :float
#  month5  :float
#  month6  :float
#  month7  :float
#  month8  :float
#  month9  :float
#  month10 :float
#  month11 :float
#  month12 :float
#

class Beekeeper::Buzzn::SepEegMonthly < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.sep_eeg_monthly'
end
