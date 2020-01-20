# coding: utf-8
require_relative 'a0x_general'

module Pdf
  class LsnA1 < A0xGeneral

    protected

    def document_name
      'Auftragseingangsbestätigung'
    end

    def build_struct
      super.tap do |h|
        h[:is_pre_contract] = true
        h[:document_name] = document_name
      end
    end

    def template_name
      '08_LSN_a01.slim'
    end

  end
end
