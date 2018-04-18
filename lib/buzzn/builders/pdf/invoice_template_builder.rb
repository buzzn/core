require_relative '../pdf'

class Builders::Pdf::InvoiceTemplate

  def build_json
  end

  def build_pdf
    Buzzn::Pdfs::InvoiceTemplate.new(build_json).to_pdf
  end

  def build_pdf_document
    PdfDocument.create(template: :invoice_template, json: build_json,
                       document: Document.store(build_pdf))
  end
end
