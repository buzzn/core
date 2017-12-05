require_relative 'datasource'

module Types::Discovergy
  module Get
    def http_method
      :get
    end
  end

  module Post
    def http_method
      :post
    end
  end

  module Delete
    def http_method
      :delete
    end
  end
end

require_relative 'discovergy/base'
require_relative 'discovergy/meters'
require_relative 'discovergy/readings'
require_relative 'discovergy/last_reading'
require_relative 'discovergy/field_names'
require_relative 'discovergy/virtual_meter'
