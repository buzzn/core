require_relative 'meter'

# see GET LastReading on https://api.discovergy.com/docs

class Types::Discovergy::FieldNames < Types::Discovergy::Meter

  def to_path; :field_names; end

  class Get < Types::Discovergy::FieldNames

    include Types::Discovergy::Get

  end

end
