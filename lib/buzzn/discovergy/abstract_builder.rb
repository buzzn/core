require_relative '../discovergy'
require_relative '../types/datasource'

class Discovergy::AbstractBuilder
  extend Dry::Initializer
  include Types::Datasource

  protected

  def to_watt(response)
    # POWER(X) is the (phase) power in 10^-3 W
    response['values']['power'] / 1000
  end
end
