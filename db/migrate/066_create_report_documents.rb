class CreateReportDocuments < ActiveRecord::Migration

    def change
      create_table :report_documents do |t|
        t.string :key, null: false
        t.string :document, null: false
      end
    end
  
end