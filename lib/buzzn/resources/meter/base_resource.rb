module Meter
  class BaseResource < Buzzn::Resource::Entity
    require_relative '../admin/comment_resource'

    abstract

    model Base

    attributes :product_serialnumber,
               :sequence_number,
               :datasource
    attributes :updatable, :deletable

    has_many :registers
    has_many :comments, Admin::CommentResource

  end
end
