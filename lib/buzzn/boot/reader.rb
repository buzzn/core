require 'dry/auto_inject/strategies'
require 'dry/auto_inject/strategies/constructor'

module Buzzn
  module Boot
    class Reader < Dry::AutoInject::Strategies::Constructor
      private

      def define_new
        class_mod.class_exec(container, dependency_map) do |container, dependency_map|
          define_method :new do |*args|
            result = super(*args)
            names = dependency_map.to_h
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
        end
      end

      def define_initialize(klass)
      end
    end
    Dry::AutoInject::Strategies.register :reader, Reader
  end
end
