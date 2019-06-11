module Admin
  class CommentResource < Buzzn::Resource::Entity

    model Comment

    attribute :content,
              :updatable,
              :deletable

  end
end
