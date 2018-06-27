module Organization
  class Base < ActiveRecord::Base

    self.table_name = :organizations

    belongs_to :address

    before_create do
      self.slug ||= Buzzn::Slug.new(self.name)
    end

    scope :permitted, ->(uids) { where(nil) } # organizations are public

  end
end
