# == Schema Information
#
# Table name: buzzndb.fahrplan_tnnt_eeg
#
#  idfp      :integer          not null
#  datum     :string(16)       not null
#  timestamp :string(32)
#  q1        :float
#  q2        :float
#  q3        :float
#  q4        :float
#  q5        :float
#  q6        :float
#  q7        :float
#  q8        :float
#  q9        :float
#  q10       :float
#  q11       :float
#  q12       :float
#  q13       :float
#  q14       :float
#  q15       :float
#  q16       :float
#  q17       :float
#  q18       :float
#  q19       :float
#  q20       :float
#  q21       :float
#  q22       :float
#  q23       :float
#  q24       :float
#  q25       :float
#  q26       :float
#  q27       :float
#  q28       :float
#  q29       :float
#  q30       :float
#  q31       :float
#  q32       :float
#  q33       :float
#  q34       :float
#  q35       :float
#  q36       :float
#  q37       :float
#  q38       :float
#  q39       :float
#  q40       :float
#  q41       :float
#  q42       :float
#  q43       :float
#  q44       :float
#  q45       :float
#  q46       :float
#  q47       :float
#  q48       :float
#  q49       :float
#  q50       :float
#  q51       :float
#  q52       :float
#  q53       :float
#  q54       :float
#  q55       :float
#  q56       :float
#  q57       :float
#  q58       :float
#  q59       :float
#  q60       :float
#  q61       :float
#  q62       :float
#  q63       :float
#  q64       :float
#  q65       :float
#  q66       :float
#  q67       :float
#  q68       :float
#  q69       :float
#  q70       :float
#  q71       :float
#  q72       :float
#  q73       :float
#  q74       :float
#  q75       :float
#  q76       :float
#  q77       :float
#  q78       :float
#  q79       :float
#  q80       :float
#  q81       :float
#  q82       :float
#  q83       :float
#  q84       :float
#  q85       :float
#  q86       :float
#  q87       :float
#  q88       :float
#  q89       :float
#  q90       :float
#  q91       :float
#  q92       :float
#  q93       :float
#  q94       :float
#  q95       :float
#  q96       :float
#

class Beekeeper::Buzzn::FahrplanTnntEeg < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.fahrplan_tnnt_eeg'
end
