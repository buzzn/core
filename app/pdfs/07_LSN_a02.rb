require_relative 'a0x_general'

module Pdf
  class LsnA2 < A0xGeneral

    protected

    def build_struct
      super.tap do |h|
      end
    end

    def template_name
      '07_LSN_a02.slim'
    end

  end
end
