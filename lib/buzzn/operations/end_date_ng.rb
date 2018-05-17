require_relative '../operations'

class Operations::EndDateNg

  def call(params:, **)
    params[:end_date] = params.delete(:last_date) + 1.day if params.key?(:last_date)
  end

end
