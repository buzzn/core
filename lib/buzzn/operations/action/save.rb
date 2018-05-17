require_relative '../action'

class Operations::Action::Save

  include Dry::Transaction::Operation

  def call(resource:, **)
    persist(resource.object)
    resource
  end

  private

  def persist(object)
    if object.changed?
      object.touch
      object.save!
    end
  end

end
