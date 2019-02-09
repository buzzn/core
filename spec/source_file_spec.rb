describe 'Source File' do

  (Dir['config/initilaizers/*rb'] + Dir['lib/**/*rb'] + Dir['app/**/*rb']).each do |file|
    it "source code files do not use Time.now in #{file}" do
      next if file == 'lib/buzzn/utils/chronos.rb'
      next if file == 'app/models/accounting/entry.rb'
      next if file == 'lib/beekeeper/importer/support/localpool_log.rb'
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
end
