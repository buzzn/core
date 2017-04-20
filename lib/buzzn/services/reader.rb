require 'dry/auto_inject/strategies'
require 'dry/auto_inject/strategies/constructor'

module Buzzn
  module Services
    class Reader < Dry::AutoInject::Strategies::Constructor
      private

      def define_new(_klass)
        class_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def new(*args)
              result = super
              names = #{dependency_map.inspect}
              deps = names.each_with_object({}) { |(name, identifier), obj|
                obj[name] = container[identifier]
              }
              deps.each do |name, dep|
                # not sure why inline string concatation does not work here
                var_name = '@' + name.to_s
                result.instance_variable_set(var_name, dep) if var_name != '@'
              end
              result
            end
          RUBY
      end

      def define_initialize(klass)
      end
    end
    Dry::AutoInject::Strategies.register :reader, Buzzn::Services::Reader
  end
end
