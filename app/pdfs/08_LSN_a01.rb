# coding: utf-8
require_relative 'a0x_general'

module Pdf
  class LsnA1 < A0xGeneral

    protected

    def build_struct
      super.tap do |h|
        h[:is_pre_contract] = true
        h[:document_name] = 'Auftragseingangsbestätigung'
      end
    end

    def template_name
      '08_LSN_a01.slim'
    end

    def document_purpose
      'lsn_a01'
    end
  end
end
