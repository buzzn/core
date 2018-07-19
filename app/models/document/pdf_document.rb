class PdfDocument < ActiveRecord::Base

  belongs_to :document
  belongs_to :template

end
