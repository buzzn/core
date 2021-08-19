require 'csv'
require 'buzzn/utils/file'

class Groups < ActiveRecord::Base

    def self.import_from_csv(file)
        data = Buzzn::Utils::File.read(file)
        CSV.parse(data.gsub(/\r\n?/, "\n"), col_sep: ';', headers: true) do |row|
            gen = row['Generation']
            group = Group::Localpool.find(Hash[row.to_a]['ID'])

            if group.nil?
                # logger.info "id not found: #{row}"
                group.not_found("id not found: '#{row}'")
            else
                if row['Generation'].match?(/\A-?\d+\Z/) == false
                    logger.info "generation = 0 as not numeric"
                elsif "#{group.generation}" != gen
                    logger.info "row: #{row} generation changed from #{group['generation']} to #{gen}"
                end
                group.update(generation: gen)
            end

        end
    end


    private
    
    def self.logger; @_logger ||= Buzzn::Logger.new(self); end

    def self.not_found(msg)
        raise Buzzn::RecordNotFound.new(self, msg)
    end
end
