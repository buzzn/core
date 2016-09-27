class ZipKa < ActiveRecord::Base
  
  def self.from_csv(data)
    delete_all
    ka = {}
    data.gsub(/\r\n?/, "\n").split("\n").uniq.sort.each do |k|
      parts = k.split(";")
      ka[parts[0]]=parts[1]
    end
    ka.delete('plz')
    ka.each do |zip, ka|
      create!(zip: zip, ka: ka)
    end
  end

  def self.to_csv(io)
    io << "plz;ka\n"
    ZipKa.all.each do |i|
      io << "#{i.zip};#{i.ka}\n"
    end
  end
end
