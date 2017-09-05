# coding: utf-8
class ZipToPrice < ActiveRecord::Base

  COLUMNS = { zip: 'Plz',
              price_euro_year_dt: 'Gesamtpreis Euro/Jahr DT',
              average_price_cents_kwh_dt: 'Durchschnittspreis ct/kWh DT',
              baseprice_euro_year_dt: 'Grundpreis Euro/Jahr DT',
              unitprice_cents_kwh_dt: 'Arbeitspreis ct/kWh DT',
              mesurement_euro_year_dt: 'MSB Euro/Jahr DT',
              baseprice_euro_year_et: 'Grundpreis Euro/Jahr ET',
              unitprice_cents_kwh_et: 'Arbeitspreis ct/kWh ET',
              mesurement_euro_year_et: 'MSB Euro/Jahr ET',
              ka: 'KA',
              state: 'Bundesland',
              comunity: 'Gemeinde',
              vdewid: 'VDEWID',
              dso: 'Netzbetreiber'}

  def self.from_csv(file)
    data = Buzzn::Utils::File.read(file)
    # none destructive update
    update_all(updated: false)
    CSV.parse(data.gsub(/\r\n?/, "\n"), col_sep: ';', headers: true) do |row|
      values = Hash[row.to_a].values
      if values.include?(nil) or values.size != 14
        warn "skip corrupted row: #{row}"
      else
        params = Hash[COLUMNS.keys.zip(values)]
        params[:updated] = true
        create!(params)
      end
    end
    where(updated: false).delete_all
  end

  def self.to_csv(io)
    io << COLUMNS.values.join(';') << "\n"
    ZipToPrice.all.each do |i|
      row = i.attributes.values[1..-2].join(';')
      io << row << "\n"
    end
  end

  scope :by_zip, ->(zip) { where(zip: zip) }
end
