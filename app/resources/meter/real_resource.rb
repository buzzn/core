module Meter
  class RealSerializer < BaseSerializer

    attributes  :smart

    has_many :registers

  end
  class GuardedRealSerializer < RealSerializer

    attributes :updatable, :deletable

    def initialize(resource, options)
      super(resource, options)
      @updatable = Set.new(options[:updatable]) if options.key? :updatable
      @deletable = Set.new(options[:deletable]) if options.key? :deletable
      @current_user = options[:current_user]
    end

    def updatable
      if @updateable
        @updateable.include? object.id
      else
        object.updatable_by?(@current_user)
      end
    end

    def deletable
      if @deletable
        @deletable.include? object.id
      else
        object.deletable_by?(@current_user)
      end
    end
  end
end
