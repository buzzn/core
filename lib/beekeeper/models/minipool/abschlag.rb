# == Schema Information
#
# Table name: minipooldb.abschlag
#
#  id_arbeit      :integer          not null, primary key
#  vertragsnummer :integer          not null
#  nummernzusatz  :integer          not null
#  arbeit         :integer          not null
#  abschlag       :float            not null
#  datum          :string(16)       not null
#  timestamp      :string(32)       not null
#  bezugspreis    :integer          not null
#

class Beekeeper::Minipool::Abschlag < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.abschlag'

  def converted_attributes
    {
      # -1 now marks that automatic payment adjust has been disabled, 0 is actually valid
      price_cents: abschlag.zero? ? -1 : abschlag*100,
      energy_consumption_kwh_pa: arbeit,
      begin_date: date_parsed,
      cycle: 'monthly'
    }
  end

  def date_parsed
    begin
      Date.parse(datum)
    rescue ArgumentError
      raise "invalid date. please fix #{self.to_json}"
    end
  end

end
