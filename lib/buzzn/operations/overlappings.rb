require_relative '../operations'

class Operations::Overlappings

  def call(resource:, params:, **)
    unless params[:last_date].nil?
      resource.register_meta.registers.each  do |r| 
        if r.contracts.any?
          r.contracts.each do |c|  
            unless c.begin_date.nil? || c.end_date.nil?
              if params[:last_date] > c.begin_date && params[:last_date] < c.end_date
                  raise Buzzn::ValidationError.new('{no_other_contract_in_range=>["there is already another contract in that time range present"]}')
              end
            end
          end
        end
      end
    end
    true
  end

end
