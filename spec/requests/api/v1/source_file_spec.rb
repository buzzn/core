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
  end
end
