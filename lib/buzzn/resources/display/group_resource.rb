require_relative '../group_resource'
module Display
  class GroupResource < ::GroupResource

    has_many :registers
    has_many :mentors

    def registers
      all(permissions.registers,
          object.registers.consumption_production,
          RegisterResource)
    end

    def mentors
      all(permissions.mentors,
          object.managers.limit(2),
          MentorResource)
    end
  end
end
