require_relative 'base_roda'
class SwaggerRoda < BaseRoda

  route do |r|

    r.is 'swagger' do
      File.read(r.path.sub(/.api/, 'lib/buzzn/roda') + '.json')
    end
  end
end
