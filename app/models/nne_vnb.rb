class NneVnb < ActiveRecord::Base

  
  def self.from_csv(data)
    delete_all
    CSV.parse(data.gsub(/\r\n?/, "\n"), col_sep: ';', headers: true) do |row|
      create!(verbandsnummer: row[0],
              typ:            row[1],
              messung_et:     row[2],
              abrechnung_et:  row[3],
              zaehler_et:     row[4],
              register_et:          row[5],
              messung_dt:     row[6],
              abrechnung_dt:  row[7],
              zaehler_dt:     row[8],
              register_dt:          row[9],
              arbeitspreis:   row[10],
              grundpreis:     row[11],
              vorlaeufig:     'WAHR' == row[12])
    end
  end

  
  def self.to_csv(io)
    io << "verbandsnummer;typ;messung_et;abrechnung_et;zaehler_et;mp_et;messung_dt;abrechnung_dt;zaehler_dt;mp_dt;arbeitspreis;grundpreis;vorlaeufig\n"
    NneVnb.all.each do |i|
      io << "#{i.verbandsnummer};#{i.typ};#{_(i.messung_et)};#{_(i.abrechnung_et)};#{_(i.zaehler_et)};#{_(i.mp_et)};#{_(i.messung_dt)};#{_(i.abrechnung_dt)};#{_(i.zaehler_dt)};#{_(i.mp_dt)};#{_(i.arbeitspreis)};#{_(i.grundpreis)};#{i.vorlaeufig ? 'WAHR' : 'FALSCH'}\n"
    end
  end

  private
  def self._(value)
    value.to_s.sub(/.0$/, '')
  end
end
