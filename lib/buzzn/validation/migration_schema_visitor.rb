module Buzzn
  module Validation
    class MigrationSchemaVisitor < SchemaVisitor

      def initialize(schema, includes: nil, excludes: [])
        super(schema)
        @includes = includes
        @excludes = excludes
      end

      def create_table(table, clazz)
        clazz.create_table(table, id: :uuid) do |t|
          change(t)

          t.timestamps null: false
        end
      end

      def include?(name)
        (@includes.nil? && !@excludes.member?(name)) || @includes.member?(name)
      end

      def change(migration)
        processor = ->(name: nil, required: nil, type: nil, options: {}) do
          next unless include?(name)
          case type
          when :enum
            # omit
          else
            db_options = { null: !required }
            db_options[:limit] = options[:max_size] if options[:max_size]
            warn "   #{type}: :#{name}, #{db_options}"
            migration.send(type, name, db_options)
          end
        end
        visit(&processor)
      end

      def up(table, clazz)
        create_table(table, clazz)
        processor = ->(name: nil, required: nil, type: nil, options: {}) do
          next unless include?(name)
          case type
          when :enum
            clazz.create_enum name, *options[:values]
            clazz.add_column table, name, name, index: true, null: true
          else
            # omit
          end
        end
        visit(&processor)
      end

      def down(table, clazz)
        processor = ->(name: nil, required: nil, type: nil, options: {}) do
          next unless include?(name)
          case type
          when :enum
            clazz.remove_column table, name
            clazz.drop_enum name
          else
            # omit
          end
        end
        visit(&processor)
        clazz.drop_table(table)
      end
    end
  end
end
