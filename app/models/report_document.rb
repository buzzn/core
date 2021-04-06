class ReportDocument < ActiveRecord::Base

    def self.load_document(key)
        report_document = self.where(key: key).first
        if report_document.nil?
            raise Buzzn::ValidationError.new("The report has not yet been completely generated.")
        else
            report_document.document
        end
    end
  
    def self.store(key, document)
      transaction do
            create(key: key, document: document)
        end
    end

    def self.delete_document(key)
        self.where(key: key).destroy_all
    end

  
  end