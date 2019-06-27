module Admin
  class CommentResource < Buzzn::Resource::Entity

    model Comment

    attribute :content,
              :author,
              :updatable,
              :deletable

  end
end
