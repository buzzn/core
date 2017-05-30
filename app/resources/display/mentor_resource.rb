module Display
  class MentorResource < Buzzn::Resource::Entity

    model User

    attributes  :title,
                :first_name,
                :last_name,
                :image

    def title
      object.profile.title
    end

    def image
      object.image.md.url
    end

    def self.to_resource(user, roles, permissions, instance, clazz = nil)
      super(user, roles, permissions, instance, clazz || self)
    end
  end
end
