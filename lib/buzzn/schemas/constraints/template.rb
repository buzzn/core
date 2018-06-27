require_relative '../constraints'
Schemas::Constraints::Template = Schemas::Support.Form do
  required(:name).value(included_in?: Dir['app/pdfs/*slim']
                         .collect { |f| File.basename(f).sub('.slim', '') }
                         .reject { |f| f == 'generator' })

  required(:version).filled(:int?)
  required(:source).filled(:str?, max_size?: 65536)
end
