require_relative '../action'

class Operations::Action::Delete

  include Dry::Transaction::Operation

  def call(resource)
    resource.object.destroy
    Success(resource)
  end

end
