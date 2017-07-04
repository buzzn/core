require_relative 'base_roda'
class SwaggerRoda < BaseRoda

  route do |r|

    r.is 'swagger.json' do
      YAML.load(File.read(r.path.sub(/.api/, 'lib/buzzn/roda').sub('.json', '.yaml')))
    end
  end
end
