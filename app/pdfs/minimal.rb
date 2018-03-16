require 'buzzn/pdf_generator'

module Buzzn::Pdfs
  class Minimal < Buzzn::PdfGenerator

    TEMPLATE = if Import.global?('config.slim.file')
                 Import.global('config.slim.file')
               else
                 'minimal.slim'
               end

  end
end
