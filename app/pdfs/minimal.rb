require 'buzzn/pdf_generator'

module Buzzn::Pdfs
  class Minimal < Buzzn::PdfGenerator

    TEMPLATE = if Import.global?('config.slim_file')
                 Import.global('config.slim_file').sub('app/pdfs/', '')
               else
                 'minimal.slim'
               end

  end
end
