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
  end
end
