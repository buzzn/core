# coding: utf-8
require_relative 'a0x_general'

module Pdf
  class LsnA1 < A0xGeneral

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Auftragseingangsbestätigung-#{contract.localpool.slug}-#{contract.contract_number}-#{contract.contract_number_addition}"
    end

    def build_struct
      super.tap do |h|
        h[:is_pre_contract] = true
        h[:document_name] = 'Auftragseingangsbestätigung'
      end
    end

    def template_name
      '08_LSN_a01.slim'
    end

  end
end
