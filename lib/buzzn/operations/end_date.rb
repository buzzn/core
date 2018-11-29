require_relative '../operations'

class Operations::EndDate

  def call(params:, **)
    if params.key?(:last_date)
      if params[:last_date].nil?
        params.delete(:last_date)
      else
        params[:end_date] = params.delete(:last_date) + 1.day
      end
    end
  end

end
