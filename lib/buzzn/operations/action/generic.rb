require_relative '../authorization'

class Operations::Action::Generic
  include Dry::Transaction::Operation

  def call(input, resource = nil)
    raise ArgumentError.new('missing resource') unless resource

    begin
      Dry::Monads.Right(do_act(input, resource))
    rescue => e
      # TODO better a Left Monad and handle on roda
      raise e
    end
  end

  def do_act(input, resource)
    raise 'not implemented'
  end
end
