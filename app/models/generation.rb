# generation.csv displays database
# i.e. all groups that should have a generation-value must be included. For groups that are not included generation is going to be set nil

class Groups < ActiveRecord::Base

    def self.import_from_csv(file)
        data = Buzzn::Utils::File.read(file)
        check = []

        CSV.parse(data.gsub(/\r\n?/, "\n"), col_sep: ';', headers: true) do |row|
            gen = row['Generation']

            begin
                group = Group::Localpool.find(Hash[row.to_a]['ID'])
            rescue ActiveRecord::RecordNotFound => e
                logger.error("group #{Hash[row.to_a]['ID']} NOT FOUND")
            end

            unless group.nil?
                if gen.nil?
                    logger.error "generation for group #{row['ID']} NOT FOUND"
                elsif gen.match?(/\A-?\d+\Z/) == false
                    gen = nil
                    logger.error "generation for group #{row['ID']} NOT NUMERIC"
                elsif "#{group.generation}" != gen
                    logger.info "generation for group #{row['ID']} changed from #{group.generation.nil? ? 'nil' : group.generation} to #{gen}"
                end
                check.push(row['ID'])
                group.update(generation: gen)

            end
        end

        Group::Localpool.all.each do |group|
            if !check.include?("#{group.id}") && !group.generation.nil?
                group.update(generation: nil)
                logger.info "generation for group #{group.id} deleted"
            end
        end

    end


    private

    def self.logger; @_logger ||= Buzzn::Logger.new(self); end

end
