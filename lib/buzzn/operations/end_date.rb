require_relative '../operations'

class Operations::EndDate

  include Dry::Transaction::Operation

  def call(input)
    input[:end_date] = input.delete(:last_date) + 1.day if input.key?(:last_date)
    Success(input)
  end

end
