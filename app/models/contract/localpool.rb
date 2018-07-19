require_relative 'base'

module Contract
  class Localpool < Base

    # NOTE: having this in breaks the factories as type is not getting set.
    #self.abstract_class = true

    belongs_to :localpool, class_name: 'Group::Localpool'

    def pdf_generator
      Pdf::LocalPoolProcessingContract
    end

  end
end
