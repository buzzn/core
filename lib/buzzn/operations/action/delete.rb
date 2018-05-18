require_relative '../action'

class Operations::Action::Delete

  def call(resource: )
    resource.object.destroy
    resource
  end

end
