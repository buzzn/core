require_relative 'base_resource'
require_relative '../group_resource'

module Contract
  class LocalpoolResource < BaseResource

    # TODO why generic GroupResource. is hits really needed by UI?
    has_one :localpool, GroupResource

    def allowed_documents
      {}.tap do |document|
        object.pdf_generators.each do |generator|
          name = generator.name.split("::").last.underscore
          precondition_method = "document_" + name
          document[name.to_sym] = (respond_to? precondition_method) ? (send(precondition_method).success? || send(precondition_method).errors) : true
        end
      end
    end

  end
end
