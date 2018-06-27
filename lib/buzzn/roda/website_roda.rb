require_relative 'base_roda'
require_relative 'website/zip_to_price_roda'
require_relative 'website/website_form_roda'

module Website
  class Roda < BaseRoda

    route do |r|

      r.on 'zip-to-price' do
        r.run Website::ZipToPriceRoda
      end

      r.on 'website-forms' do
        r.run Website::WebsiteFormRoda
      end

      r.run SwaggerRoda
    end

  end
end
