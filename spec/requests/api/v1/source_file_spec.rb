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
end
