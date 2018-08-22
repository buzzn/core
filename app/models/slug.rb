class Slug < ActiveRecord::Base

  def self.get_next(namespace, basename)
    base = self.where(:namespace => namespace, :basename => basename).first
    if base.nil?
      0
    else
      base.count
    end
  end

  def self.commit(namespace, basename, slug)
    base = self.where(:namespace => namespace, :basename => basename).first
    if base.nil?
      self.create(:namespace => namespace, :basename => basename, :last_slug => slug, :count => 1)
    else
      base.last_slug = slug
      base.count = base.count + 1
      base.save
    end
  end

end
