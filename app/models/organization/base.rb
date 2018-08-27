module Organization
  class Base < ActiveRecord::Base

    self.table_name = :organizations

    belongs_to :address

    before_save :check_slug
    before_create :check_slug

    scope :permitted, ->(uids) { where(nil) } # organizations are public

    private

    def check_slug
      if self.slug.nil?
        baseslug = Buzzn::Slug.new(self.name)

        self.slug = baseslug

        count = Slug.get_next('organization', baseslug)
        if count.positive? || self.class.where(:slug => self.slug).any?
          self.slug = Buzzn::Slug.new(self.name, count)
        end
        Slug.commit('organization', baseslug, self.slug)
      end
    end

  end
end
