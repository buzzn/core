module Display
  class MentorResource < Buzzn::Resource::Entity

    model Person

    attributes  :title,
                :first_name,
                :last_name,
                :image

    def image
      #user = User.where(person: object).first
      object.image.md.url #if user
    end
  end
end
