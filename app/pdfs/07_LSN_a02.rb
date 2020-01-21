# coding: utf-8
require_relative 'a0x_general'

module Pdf
  class LsnA2 < A0xGeneral

    protected

    def document_name
      'Auftragsbestätigung'
    end

    def build_struct
      super.tap do |h|
        h[:document_name] = document_name
      end
    end

    def template_name
      '07_LSN_a02.slim'
    end

  end
end
