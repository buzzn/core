#
# run with:
# bundle exec ruby script/discovergy_api.rb
#

require ::File.expand_path('../../config/buzzn', __FILE__)
require 'awesome_print'

class Disco

  include Import['services.datasource.discovergy.api']

  def disco(group)
    registers = group.registers.consumption_production.includes(:meter)
    builder = Builders::Discovergy::BubbleBuilder.new(registers: registers)
    collection(group, builder, :power)
  end

  def collection(group, builder, *fields)
    if meter = Meter::Discovergy.where(group: group).first
      api_call(meter, fields, true, builder)
    end
  end

  def api_call(meter, fields, each, builder)
    query = Types::Discovergy::LastReading::Get.new(meter: meter,
                                                    fields: fields,
                                                    each:   each)
    api.request(query, builder)
  end
end

group = Group::Base.find_by(slug: 'heigelstrasse')
ap group.present?
ap Disco.new.disco(group)

api = Services::Datasource::Discovergy::Api.new
ap api.raw_request('/readings')
