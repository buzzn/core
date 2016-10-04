class ZipVnb < ActiveRecord::Base

  def self.from_csv(data)
    delete_all
    done = {}
    CSV.parse(data.gsub(/\r\n?/, "\n"), col_sep: ';', headers: true) do |row|
      key = "#{row[0]}#{row[1]}#{row[2]}"
      if ! done.key?(key) && row[2]
        done[key] = 0
        create!(zip: row[0], place: row[1], verbandsnummer: row[2]) 
      end
    end
  end

  def self.to_csv(io)
    io << "plz;ort;verbandsnummer;\n"
    ZipVnb.all.each do |i|
      io << "#{i.zip};#{i.place};#{i.verbandsnummer};\n"
    end
  end
end
