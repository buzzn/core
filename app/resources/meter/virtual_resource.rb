module Meter
  class VirtualSerializer < BaseSerializer

    has_one :register

  end
  class GuardedVirtualSerializer < VirtualSerializer

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
