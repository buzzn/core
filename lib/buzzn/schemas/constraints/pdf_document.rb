require_relative '../constraints'

Schemas::Constraints::PdfDocument = Schemas::Support.Form do
  required(:json).filled(:str?, max_size?: 16384)
end
