class Roda
  module RodaPlugins
    module CreatedDeleted
      module InstanceMethods

        def deleted
          response.status = 204
          yield
          ''
        end

        def created
          response.status = 201
          yield
        end
      end
    end

    register_plugin(:created_deleted, CreatedDeleted)
  end
end
