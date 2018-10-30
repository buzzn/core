module Buzzn
  module Utils

    class Helpers

      def self.symbolize_keys_recursive(hash)
        unless hash.class == Hash
          return hash
        end

        Hash[hash.map do |key, value|
               if value.class == Hash
                 [key.to_sym, symbolize_keys_recursive(value)]
               elsif value.class == Array
                 value.map { |e| symbolize_keys_recursive(e) }
               else
                 [key.to_sym, value]
               end
             end
            ]
      end

    end
  end
end
