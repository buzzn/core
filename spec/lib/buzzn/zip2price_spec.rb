require 'buzzn/zip2price'
require 'stringio'

describe Buzzn::Zip2Price do

  let(:csv_dir) { 'db/csv' }
  let(:zip_vnb) { File.read(File.join(csv_dir, "plz_vnb_test.csv")) }
  let(:zip_ka) { File.read(File.join(csv_dir, "plz_ka_test.csv")) }
  let(:nne_vnb) { File.read(File.join(csv_dir, "nne_vnb.csv")) }
  let(:full_zip_vnb) { File.read(File.join(csv_dir, "plz_vnb.csv")) }
  let(:full_zip_ka) { File.read(File.join(csv_dir, "plz_ka.csv")) }
  let(:full_nne_vnb) { File.read(File.join(csv_dir, "nne_vnb.csv")) }

  # it "from csv for #{ZipVnb}", :slow do
  #   ZipVnb.from_csv(full_zip_vnb)
  #   csv = StringIO.new
  #   ZipVnb.to_csv(csv)
  #
  #   expected = full_zip_vnb.gsub(/;[^;]+$/, ';').sub(/^.*;;$/, '').split("\n").uniq.join("\n")
  #
  #   expect(csv.string.split("\n").sort.join("\n")).to eq expected.split("\n").sort.join("\n")
  #
  #   ZipVnb.from_csv(zip_vnb)
  #   # adjust the expectation when underlying file changed
  #   expect(ZipVnb.count).to eq 898
  # end
  #
  # it "from csv for #{ZipKa}", :slow do
  #   ZipKa.from_csv(full_zip_ka)
  #   csv = StringIO.new
  #   ZipKa.to_csv(csv)
  #
  #   # take only the biggest value
  #   ka = { 'plz' => 'ka' }
  #   full_zip_ka.split("\n").uniq.sort.each do |k|
  #     parts = k.split(";")
  #     ka[parts[0]]=parts[1] unless parts[0] == 'plz'
  #   end
  #   expect(csv.string.strip).to eq ka.collect{|c| c.join(";")}.join("\n").strip
  #
  #   ZipKa.from_csv(zip_ka)
  #   # adjust the expectation when underlying file changed
  #   expect(ZipKa.count).to eq 1059
  # end
  #
  # it "from csv for #{NneVnb}", :slow do
  #   NneVnb.from_csv(full_nne_vnb)
  #   csv = StringIO.new
  #   NneVnb.to_csv(csv)
  #
  #   expect(csv.string.strip).to eq full_nne_vnb.gsub(/\r\n?/, "\n").strip
  #
  #   NneVnb.from_csv(nne_vnb)
  #   expect(NneVnb.count).to eq nne_vnb.split("\n").size - 1
  # end
  #
  # it 'finds max of array of Prices' do
  #   array = [Buzzn::Price.new(0, 0, 23),
  #            Buzzn::Price.new(0, 0, 123),
  #            Buzzn::Price.new(0, 0, 3)]
  #   expect(array.max).to eq array[1]
  # end
  #
  # it 'converts zip to price' do
  #   ZipKa.from_csv(zip_ka)
  #   ZipVnb.from_csv(zip_vnb)
  #   NneVnb.from_csv(nne_vnb)
  #
  #   Buzzn::Zip2Price.types.each do |type|
  #     zip_2_price = Buzzn::Zip2Price.new(1000, 12345, type)
  #     expect(zip_2_price.to_price).to be_nil
  #     expect(zip_2_price.known_type?).to be true
  #     expect(zip_2_price.ka?).to be true
  #     zip_2_price = Buzzn::Zip2Price.new(1000, 98765, type)
  #     expect(zip_2_price.to_price).to be_nil
  #     expect(zip_2_price.known_type?).to be true
  #     expect(zip_2_price.ka?).to be false
  #   end
  #
  #   zip_2_price = Buzzn::Zip2Price.new(1000, 98765, 'unknown')
  #   expect(zip_2_price.to_price).to be_nil
  #   expect(zip_2_price.known_type?).to be false
  #   expect(zip_2_price.ka?).to be false
  #
  #   zip_2_price = Buzzn::Zip2Price.new(1000, 12345, 'unknown')
  #   expect(zip_2_price.to_price).to be_nil
  #   expect(zip_2_price.known_type?).to be false
  #   expect(zip_2_price.ka?).to be true
  #
  #   Hash[Buzzn::Zip2Price.types
  #         .zip([[1170, 2560, 3303],
  #               [1330, 2560, 3463],
  #               [910, 2560, 3043],
  #               [1170, 2560, 3303],
  #               [1170, 2560, 3303]])].each do |type, expected|
  #     zip_2_price = Buzzn::Zip2Price.new(1000, 86916, type)
  #     expect(zip_2_price.to_price.baseprice_cents_per_month).to eq expected[0]
  #     expect(zip_2_price.to_price.energyprice_cents_per_kilowatt_hour).to eq expected[1]
  #     expect(zip_2_price.to_price.total_cents_per_month).to eq expected[2]
  #     expect(zip_2_price.known_type?).to be true
  #     expect(zip_2_price.ka?).to be true
  #   end
  #
  #
  #   Hash[Buzzn::Zip2Price.types
  #         .zip([[1150, 2630, 23067],
  #               [1280, 2630, 23197],
  #               [940, 2630, 22857],
  #               [1150, 2630, 23067],
  #               [1150, 2630, 23067]])].each do |type, exp|
  #     zip_2_price = Buzzn::Zip2Price.new(10000, 37181, type)
  #     expect(zip_2_price.to_price.baseprice_cents_per_month).to eq exp[0]
  #     expect(zip_2_price.to_price.energyprice_cents_per_kilowatt_hour).to eq exp[1]
  #     expect(zip_2_price.to_price.total_cents_per_month).to eq exp[2]
  #     expect(zip_2_price.known_type?).to be true
  #     expect(zip_2_price.ka?).to be true
  #   end
  # end
end
