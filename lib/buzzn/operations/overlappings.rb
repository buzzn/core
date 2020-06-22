require_relative '../operations'

class Operations::Overlappings

  def call(params:, contract:, **)
    !contract.register_meter.registers.any |r| do
        if r.contracts.any{|c| params[:last_date] > c.begin && params[:last_date] < c.end}
            raise Buzzn::ValidationError.new(datasource: 'new date cannot be set: overlapping contract dates')
        end
    end
  end

end
