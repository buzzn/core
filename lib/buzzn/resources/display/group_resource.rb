require_relative '../group_resource'
require_relative 'register_resource'

module Display
  class GroupResource < ::GroupResource

    has_many :registers, RegisterResource
    has_many :mentors

    def self.filter_all(objects)
      objects.where(show_display_app: true)
    end

    def mentors
      all(permissions.mentors,
          object.managers.limit(2),
          MentorResource)
    end
  end
end
