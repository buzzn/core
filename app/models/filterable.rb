# inspired by: https://gist.github.com/justinweiss/9065666
module Filterable

  extend ActiveSupport::Concern

  module ClassMethods

    def filter(search_value)
      raise 'implement a filter method by calling do_filter(search_value, :attr1, nested_resource1: [:attr2, :attr3])'
    end

    private
    # filtering_params are either a list of attributes of the model or
    # a hash for nested resources.
    # NOTE: the nested resource can not be null until AR can handle left outer
    #       join
    def do_filter(value, *filtering_params)
      return self.all if value.nil?
      value = value[:filter] if value.is_a?(Hash)
      sql = []
      result = nested(sql, self.where(nil), # create an anonymous scope
                      table_name, *filtering_params)
      result.where(sql.join(' or '),
                   *sql.size.times.collect { "%#{value}%" } )
    end

    def nested(sql, result, prefix, *filtering_params)
      filtering_params.each do |param|
        case param
        when Hash
          param.each do |k, v|
            result = nested(sql, result.joins(k), k.to_s.tableize, v)
          end
        when Array
          param.each do |k|
            sql << "#{prefix}.#{k} ilike ?"
          end
        else
          sql << "#{prefix}.#{param} ilike ?"
        end
      end
      result
    end

  end

end
