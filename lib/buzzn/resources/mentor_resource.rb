class MentorResource < Buzzn::Resource::Entity

  model User

  attributes  :first_name,
              :last_name,
              :image

  def image
    object.image.md.url
  end
end
