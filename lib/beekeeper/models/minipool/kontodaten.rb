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

class Beekeeper::Minipool::Kontodaten < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.kontodaten'

  def converted_attributes
    {
      holder:       kontoinhaber,
      iban:         kontonummer.gsub(' ', ''),
      bank_name:    bank_name,
      bic:          bic,
      direct_debit: direct_debit,
    }
  end

  private

  def direct_debit
    case einzugsermaechtigung
    when 1
      true
    when 0
      false
    else
      raise "unknown einzugsermaechtigung: '#{einzugsermaechtigung}'"
    end
  end

  def bank
    cleaned = kontonummer.gsub(' ', '')
    unless cleaned.empty?
      @bank ||= Bank.find_by_iban(cleaned)
    end
  end

  def bank_name
    bank&.description
  end

  def bic
    bank&.bic
  end

end
