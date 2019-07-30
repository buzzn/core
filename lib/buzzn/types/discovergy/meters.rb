require_relative 'base'

# see GET Meters on https://api.discovergy.com/docs

class Types::Discovergy::Meters < Types::Discovergy::Base

  def to_path; :meters; end

  class Get < Types::Discovergy::Meters

    include Types::Discovergy::Get

  end

end
