# == Schema Information
#
# Table name: buzzndb.account_new
#
#  marktplatz_id           :integer
#  fibunr                  :integer          not null, primary key
#  gesellschafts_name      :string(100)
#  strasse                 :string(45)
#  hausnummer              :string(45)
#  plz                     :string(6)
#  stadt                   :string(25)
#  bundesland              :string(40)
#  telefon                 :string(20)
#  fax                     :string(45)
#  email                   :string(45)
#  privat1_gbr2_weg3_else4 :string(20)
#  comment                 :text
#  timestamp               :string(32)
#  vertreter               :string(100)
#

class Beekeeper::Buzzn::AccountNew < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.account_new'
  include Beekeeper::StringCleaner

  def converted_attributes(bank_accounts = [])
    {
      name:          gesellschafts_name,
      phone:         telefon,
      fax:           fax,
      email:         clean_string(email, downcase: true),
      address:       address,
      bank_accounts: bank_accounts,
      contact:       contact
    }
  end

  private

  def converted_address_attributes
    {
      street:   "#{strasse} #{hausnummer}",
      zip:      plz,
      city:     stadt,
      country:  'DE',
    }
  end

  def address
    Address.new(converted_address_attributes)
  end

  def contact
    Person.new(kontakt_acc.converted_attributes)
  end

  def kontakt_acc
    Beekeeper::Buzzn::KontaktAcc.find_by(fibunr: fibunr)
  end

end
