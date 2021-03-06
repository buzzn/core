require_relative '../group_resource'
require_relative 'register_resource'
require_relative 'mentor_resource'

module Display
  class GroupResource < ::GroupResource

    has_many :registers, RegisterResource
    has_many :mentors, MentorResource

    def self.filter_all(objects)
      objects.where(show_display_app: true)
    end

  end
end
