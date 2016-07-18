# adjust from: https://gist.github.com/justinweiss/9065666
# Call scopes directly from your URL params:
#
#     @products = Product.filter(params.slice(:status, :location, :starts_with))
module Filterable
  extend ActiveSupport::Concern

  module ClassMethods

    # Call the class methods with the same name as the keys in <tt>filtering_params</tt>
    # with their associated values. Most useful for calling named scopes from
    # URL params. Make sure you don't pass stuff directly from the web without
    # whitelisting only the params you care about first!
    def filter(filtering_params)
      results = filtering_params.nil? || filtering_params.empty? ? all : []
      filtering_params.each do |key, value|
        raise "no filtering scope for '#{key}'" unless self.respond_to?(key)
        results += public_send(key, value) if value.present?
      end
      results.uniq
    end
  end
end
