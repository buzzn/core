require_relative '../action'

class Operations::Action::Update
  include Dry::Transaction::Operation

  def call(input, resource = nil)
    raise ArgumentError.new('missing resource') unless resource

    # we deliver only millis to client and have to nil the nanos
    if (resource.object.updated_at.to_f * 1000).to_i != (input.delete(:updated_at).to_f * 1000).to_i
      # TODO better a Left Monad and handle on roda
      raise Buzzn::StaleEntity.new(resource.object)
    else
      update(input, resource)
    end
  end

  def update(input, resource)
    resource.object.class.transaction do
      resource.object.attributes = input
      result = check_invariant(resource.object)
      if result.success?
        persist(resource.object)
        Right(resource)
      else
        # TODO ? resource.reload
        Left(result)
      end
    end
  end

  def persist(object)
    if object.changed?
      object.touch
      object.save!
    end
  end

  ALWAYS_SUCCESS = Object.new.tap do |o|
    def o.success?; true; end
  end

  def check_invariant(object)
    invariant = find_invariant(object.class)
    if invariant
      invariant.call(object.attributes)
    else
      ALWAYS_SUCCESS
    end
  end

  def find_invariant(clazz)
    if clazz != ActiveRecord::Base
      invariant = "#{Schemas::Invariants}::#{clazz}".safe_constantize
      invariant || find_invariant(clazz.superclass)
    end
  end
end
