# == Schema Information
#
# Table name: minipooldb.minipool_preise
#
#  vertragsnummer :integer          not null
#  grundpreis     :float            not null
#  bezugspreis    :float            not null
#  datum          :string(16)       not null
#  id             :integer          not null, primary key
#

class Beekeeper::Minipool::MinipoolPreise < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.minipool_preise'

  def converted_attributes
    {
      baseprice_cents_per_month: baseprice_cents_per_month,
      energyprice_cents_per_kwh: bezugspreis,
      begin_date: datum
    }
  end

  def baseprice_cents_per_month
    (BigDecimal.new(grundpreis.to_s) * 100).round(2)
  end

end
