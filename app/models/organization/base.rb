module Organization
  class Base < ActiveRecord::Base

    self.table_name = :organizations

    belongs_to :address

    before_save do
      if self.slug.nil?
        self.slug = Buzzn::Slug.new(self.name)
        if (count = self.class.where("slug like ?", self.slug + '%').count).positive?
          self.slug = Buzzn::Slug.new(self.name, count)
        end
      end
    end

    scope :permitted, ->(uids) { where(nil) } # organizations are public

  end
end
