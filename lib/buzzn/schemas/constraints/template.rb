require_relative '../constraints'
Schemas::Constraints::Template = Schemas::Support.Form do
  required(:name).value(included_in?: Dir['app/pdfs/*rb'].collect do |f|
                          File.basename(f).sub('.rb', '')
                        end)
  required(:version).filled(:int?)
  required(:source).filled(:str?, max_size?: 65536)
end
