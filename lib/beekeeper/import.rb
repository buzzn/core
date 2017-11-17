class Beekeeper::Import
  class << self
    def run!
      new.run
    end
  end

  def run
    import_localpools
  end

  def import_localpools
    Beekeeper::MinipoolObjekte.to_import.each do |record|
      # puts
      # puts record.converted_attributes.map { |k, v| "#{k}: #{v}" }.join("\n")
      Group::Localpool.create!(record.converted_attributes)
    end
  end

  # Not used yet, created in the prototype.
  # def import_registers
  #   Beekeeper::MsbZählwerkDaten.all.each do |record|
  #     ap({ record.register_nr => record.converted_attributes })
  #   end
  # end
end
