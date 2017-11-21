# == Schema Information
#
# Table name: buzzndb.konto
#
#  marktplatz_id   :integer          not null, primary key
#  produkt         :string(45)
#  kontoinhaber    :string(45)
#  kontonummer     :string(45)
#  blz             :string(11)
#  kreditinstitut  :string(45)
#  unternehmer_ja1 :string(40)
#  umsatzsteuerid  :string(45)
#  steuersatz      :string(15)
#  steuernummer    :string(45)
#  fibunr          :integer
#  einzugserm      :string(3)
#  erstelldatum    :datetime
#

class Beekeeper::Buzzn::Konto < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.konto'

  def converted_attributes
    {
      holder:       kontoinhaber,
      iban:         kontonummer,
      bank_name:    bank_name,
      bic:          bic,
      direct_debit: direct_debit,
      created_at:   erstelldatum
    }
  end

  private

  def direct_debit
    case einzugserm.strip
    when 'J'
      true
    when 'N'
      false
    else
      raise "unknown einzugserm: '#{einzugserm}'"
    end
  end

  def bank
    @bank ||= Bank.find_by_iban(kontonummer)
  end

  def bank_name
    bank.description
  end

  def bic
    bank.bic
  end
end
