require_relative 'meter'

# see GET LastReading on https://api.discovergy.com/docs

class Types::Discovergy::LastReading < Types::Discovergy::Meter

  option :fields, Types::Strict::Array.member(Types::Strict::Symbol)
  option :each, Types::Strict::Bool, optional: true

  def to_path; :last_reading; end

  class Get < Types::Discovergy::LastReading

    include Types::Discovergy::Get

  end

end
