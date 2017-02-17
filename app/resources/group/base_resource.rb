module Group
  class BaseResource < JSONAPI::Resource
    model_name 'Group::Base'

    attributes  :name,
                :description,
                :big_tumb,
                :md_img,
                :readable

    has_many :registers
    has_many :devices
    has_many :managers
    has_many :energy_producers
    has_many :energy_consumers

    def md_img
      @model.image.md.url
    end

    def big_tumb
      @model.image.big_tumb.url
    end

  end
end
