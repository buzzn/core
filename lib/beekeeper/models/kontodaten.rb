# == Schema Information
#
# Table name: minipooldb.kontodaten
#
#  vertragsnummer       :integer          not null
#  nummernzusatz        :integer          not null
#  kontoinhaber         :string(40)       not null
#  kontonummer          :string(40)       not null
#  blz                  :string(40)       not null
#  kreditinstitut       :string(40)       not null
#  einzugsermaechtigung :integer          not null
#  ust_pflicht          :integer          not null
#  steuernummer         :string(20)       not null
#  ust_id               :string(20)       not null
#  steuersatz           :float            not null
#  sepa_mandref         :string(40)       not null
#  sepa_glaeubiger_id   :string(40)       not null
#

class Beekeeper::Kontodaten < Beekeeper::BaseRecord
  self.table_name = 'minipooldb.kontodaten'
end
