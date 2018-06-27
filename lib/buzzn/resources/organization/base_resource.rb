require_relative '../organization'

module Organization
  class BaseResource < Buzzn::Resource::Entity

    model Organization::Base

    attributes :name,
               :phone,
               :fax,
               :website,
               :email,
               :description

    attributes :updatable, :deletable

    has_one :address

  end
end
