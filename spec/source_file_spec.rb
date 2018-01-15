describe "Source File" do

  (Dir['config/initilaizers/*rb'] + Dir['lib/**/*rb'] + Dir['app/**/*rb']).each do |file|
    it "source code files do not use Time.now in #{file}" do
      next if file == 'lib/buzzn/utils/chronos.rb'
      content = File.read(file)
      content.each_line do |line|
        expect(line).not_to match /Time.now/
      end
    end
    it "source code files do not use ENV in #{file}" do
      next if file == 'lib/buzzn/boot/main_container.rb'
      content = File.read(file)
      content.each_line do |line|
        expect(line).not_to match /ENV/
      end
    end
  end

   (Dir['lib/**/*rb'] + Dir['app/**/*rb'] + Dir['app/**/*rb']).each do |file|
     it "source code files do not use binding.pry in #{file}" do
       content = File.read(file)
       content.each_line do |line|
         expect(line).not_to match /binding.pry/
       end
     end
   end
end
