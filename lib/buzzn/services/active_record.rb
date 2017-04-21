require 'dry/auto_inject/strategies'
require 'dry/auto_inject/strategies/constructor'

module Buzzn
  module Services
    class ActiveRecord < Dry::AutoInject::Strategies::Constructor
      private

      def define_new(_klass)
      end

      def define_initialize(klass)
        instance_mod.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def included(model)
            if model.respond_to?:table_name
              model.class_eval <<-RUBY_, __FILE__, __LINE__ + 1
                after_initialize do |object|
                  names = #{dependency_map.inspect}
                  deps = names.each_with_object({}) { |(name, identifier), obj|
                    obj[name] = self.class.container[identifier]
                  }
                  deps.each do |name, dep|
                    # not sure why inline string concatation does not work here
                    var_name = '@' + name.to_s
                    object.instance_variable_set(var_name, dep) if var_name != '@'
                  end
                end
              RUBY_
            end
          end
        RUBY
      end
    end
    Dry::AutoInject::Strategies.register :active_record, Buzzn::Services::ActiveRecord
  end
end
