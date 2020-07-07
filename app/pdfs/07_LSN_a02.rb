# coding: utf-8
require_relative 'a0x_general'

module Pdf
  class LsnA2 < A0xGeneral

    protected

    def build_struct
      super.tap do |h|
        h[:document_name] = 'Auftragsbestätigung'
      end
    end

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Auftragsbestätigung-#{contract.localpool.base_slug}-#{contract.contract_number}-#{contract.contract_number_addition}-#{contract.contact.last_name}"
    end

    def template_name
      '07_LSN_a02.slim'
    end

  end
end
