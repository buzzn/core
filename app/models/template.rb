class Template < ActiveRecord::Base

  def readonly?
    !new_record?
  end

  before_create do
    self.version = Template.where(name: name).count + 1
  end

end
