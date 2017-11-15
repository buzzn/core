module Display
  class MentorResource < Buzzn::Resource::Entity

    model Person

    attributes  :title,
                :first_name,
                :last_name,
                :image

    def image
      object.image.md.url
    end
  end
end
