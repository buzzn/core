module Group
  class BaseSerializer < ActiveModel::Serializer

    attributes  :name,
                :description,
                :big_tumb,
                :md_img,
                :readable

    has_many :registers
    #has_many :devices
    has_many :managers
    has_many :energy_producers
    has_many :energy_consumers

    def md_img
      object.image.md.url
    end

    def big_tumb
      object.image.big_tumb.url
    end

  end
  class GuardedSerializer < BaseSerializer

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
