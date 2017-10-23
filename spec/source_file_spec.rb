describe "Source File" do

  Dir[File.expand_path('../../../../../app/controllers/api/v1/*.rb', __FILE__)].each do |file|

    if !file.end_with?('base.rb') && !file.end_with?('defaults.rb')
      it "#{file.sub(/.*api/, 'api')} only permitted_params are allowed" do
        content = File.read(file)
        content.each_line do |line|
          if line =~ /params/
            expect(line).to match /(params do)|(permitted_params)/
          end
        end
      end
    end

    if !file.end_with?('users.rb')
      it "#{file.sub(/.*api/, 'api')} only guarded/unguarded retrieve/delete" do
        content = File.read(file)
        content.each_line do |line|
          expect(line).not_to match /find[^_]/
          if line =~ /delete/
            expect(line).to match /(delete.*do)|(guarded_delete)|(deleted_response)/
          end
        end
      end
    end
    it "#{file.sub(/.*api/, 'api')} only guarded create/update" do
      content = File.read(file)
      content.each_line do |line|
        expect(line).not_to match /(cre|upd)ate\!/
      end
    end
  end

  (Dir['lib/**/*rb'] + Dir['app/**/*rb']).each do |file|
    it "source code files do not use Time.now in #{file}" do
      next if file == 'lib/buzzn/utils/chronos.rb'
      content = File.read(file)
      content.each_line do |line|
        expect(line).not_to match /Time.now/
      end
    end
  end

  (Dir['lib/**/*rb'] + Dir['app/models/*rb'] + Dir['app/controller/api/**/*rb']).each do |file|
    next if file =~ /localpool_resource.rb/
    ['add_role', 'remove_role'].each do |roler|
      it "source code files do not use #{roler} in #{file}" do
        content = File.read(file)
        content.each_line do |line|
          expect(line).not_to match /#{roler}/
        end
      end
    end
  end
end
